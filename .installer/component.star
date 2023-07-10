name = "dns-management"
ocm_name = "github.com/gardener/external-dns-management"
version = version_file("VERSION")

dependencies = {
    "users": "*",
    "play-landscape": "*"
}

imports = [
    "play-landscape.components.dnsManagement as dns",
    "users.users.technicalUsers as users"
]

def aws(user):
    data = {
      "AWS_ACCESS_KEY_ID": user.id,
      "AWS_SECRET_ACCESS_KEY": user.secret,
      "AWS_REGION": user.region
    }
    return data


def alicloud(user):
    data = {
      "ACCESS_KEY_ID": user.keyID,
      "ACCESS_KEY_SECRET": user.keySecret,
    }
    return data


def find_user(users, type_short, username):
    for provider_users in users[type_short].values():
      for provider_user in provider_users.users:
        if provider_user.name == username:
          return provider_user


# augment provider object
def new_provider(provider, users, dns_class):
    u_provider = unbox(provider)
    if "dnsclass" not in provider:
        u_provider["dnsclass"] = dns_class

    if provider.type == "aws-route53":
        u_provider["type_short"] = "aws"
    elif provider.type == "alicloud-dns":
        u_provider["type_short"] = "alicloud"
    else:
        return (None, "Provider type {} not supported".format(provider.type))

    if "userRef" in provider:
        user = find_user(users, u_provider["type_short"], provider.userRef)
        if not user:
            return (None, "User {} configured for provider {} not found".format(provider.userRef, provider.name))
        u_provider["credentials"] = aws(user) if u_provider["type_short"] == "aws" else alicloud(user)
    elif "secret" in provider:
        if not provider.secret.data:
            return (None, "Secret data for dns provider {} not found".format(provider.name))
        u_provider["credentials"] = provider.secret.data
    else:
        return (None, "Missing user information for provider {}".format(provider.name))    

    return (box(u_provider), None)


def generate_values(images, deployment_values, dnsclass, kube_system_uid):
    image = find_image(images, "dns-controller-manager")
    image_parts = image.split(":")
    if len(image_parts) != 2:
        return (None, "unexpected value '{value}' for image {name}".format(name="dns-management", value=image))
    values = {
        "image": {
            "repository": image_parts[0],
            "tag": image_parts[1],
        },
        "fullnameOverride": "external-dns-management",
        "createCRDs": "true",
        "replicaCount": "1",
        "configuration": {
            "controllers": "dnscontrollers",
            "dnsClass": dnsclass,
            "identifier": kube_system_uid,
        },
    }

    values = merge_dict(deployment_values, values)
    return (values, None)

def validate_static(params):
    return (None, None)


def validate_predeploy(params):
    return None


def deploy(params):
    errors = []
    for dns_cfg in params.imports.dns:
        if dns_cfg.cluster.type != "garden-runtime":
            # TODO: handle other cluster types than garden-runtime cluster
            print("TODO: Will not consider cluster {} of type {} for now".format(dns_cfg.cluster.name, dns_cfg.cluster.type))
            continue

        if dns_cfg.deployment:
            # install dns-management
            namespace = dns_cfg.deployment.get("namespace")
            if not namespace:
                namespace = "garden"

            kube_system_ns, error = kubectl_get("namespace kube-system")
            if error:
                return (None, ["Could not get kube-system namespace for cluster {}".format(dns_cfg.cluster.name)])
            
            helm_values, err = generate_values(params.images, dns_cfg.deployment["values"], dns_cfg.get("dnsclass"), kube_system_ns.metadata.uid)
            if err:
                errors.append(err)
            else:
                _, err = helm_upgrade(
                    path="resources/charts/external-dns-management",
                    namespace=namespace,
                    create_namespace=True,
                    release="external-dns-management",
                    values=helm_values,
                    update_state=True,
                )
                if err:
                    errors.append(err)

        # TODO: implement handling for soil clusters
        # in case this is a fresh soil, at least DNSProvider CRD + provider namespaces are needed to continue here


        # render and deploy providers
        for p in dns_cfg.providers:
            provider, err = new_provider(p, params.imports.users, dns_cfg.get("dnsclass"))
            if err:
                errors.append(err)
                continue
            tmp_file = write_tempfile(single_file_helm_template("resources/dns-provider.yaml", provider))
            _, err = kubectl_apply("-f", tmp_file, update_state=True)
            if err:
                errors.append(err)

    return (None, errors)
