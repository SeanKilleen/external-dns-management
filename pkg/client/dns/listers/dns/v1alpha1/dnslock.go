/*
Copyright (c) 2023 SAP SE or an SAP affiliate company. All rights reserved. This file is licensed under the Apache Software License, v. 2 except as noted otherwise in the LICENSE file

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Code generated by lister-gen. DO NOT EDIT.

package v1alpha1

import (
	v1alpha1 "github.com/gardener/external-dns-management/pkg/apis/dns/v1alpha1"
	"k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/labels"
	"k8s.io/client-go/tools/cache"
)

// DNSLockLister helps list DNSLocks.
// All objects returned here must be treated as read-only.
type DNSLockLister interface {
	// List lists all DNSLocks in the indexer.
	// Objects returned here must be treated as read-only.
	List(selector labels.Selector) (ret []*v1alpha1.DNSLock, err error)
	// DNSLocks returns an object that can list and get DNSLocks.
	DNSLocks(namespace string) DNSLockNamespaceLister
	DNSLockListerExpansion
}

// dNSLockLister implements the DNSLockLister interface.
type dNSLockLister struct {
	indexer cache.Indexer
}

// NewDNSLockLister returns a new DNSLockLister.
func NewDNSLockLister(indexer cache.Indexer) DNSLockLister {
	return &dNSLockLister{indexer: indexer}
}

// List lists all DNSLocks in the indexer.
func (s *dNSLockLister) List(selector labels.Selector) (ret []*v1alpha1.DNSLock, err error) {
	err = cache.ListAll(s.indexer, selector, func(m interface{}) {
		ret = append(ret, m.(*v1alpha1.DNSLock))
	})
	return ret, err
}

// DNSLocks returns an object that can list and get DNSLocks.
func (s *dNSLockLister) DNSLocks(namespace string) DNSLockNamespaceLister {
	return dNSLockNamespaceLister{indexer: s.indexer, namespace: namespace}
}

// DNSLockNamespaceLister helps list and get DNSLocks.
// All objects returned here must be treated as read-only.
type DNSLockNamespaceLister interface {
	// List lists all DNSLocks in the indexer for a given namespace.
	// Objects returned here must be treated as read-only.
	List(selector labels.Selector) (ret []*v1alpha1.DNSLock, err error)
	// Get retrieves the DNSLock from the indexer for a given namespace and name.
	// Objects returned here must be treated as read-only.
	Get(name string) (*v1alpha1.DNSLock, error)
	DNSLockNamespaceListerExpansion
}

// dNSLockNamespaceLister implements the DNSLockNamespaceLister
// interface.
type dNSLockNamespaceLister struct {
	indexer   cache.Indexer
	namespace string
}

// List lists all DNSLocks in the indexer for a given namespace.
func (s dNSLockNamespaceLister) List(selector labels.Selector) (ret []*v1alpha1.DNSLock, err error) {
	err = cache.ListAllByNamespace(s.indexer, s.namespace, selector, func(m interface{}) {
		ret = append(ret, m.(*v1alpha1.DNSLock))
	})
	return ret, err
}

// Get retrieves the DNSLock from the indexer for a given namespace and name.
func (s dNSLockNamespaceLister) Get(name string) (*v1alpha1.DNSLock, error) {
	obj, exists, err := s.indexer.GetByKey(s.namespace + "/" + name)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NewNotFound(v1alpha1.Resource("dnslock"), name)
	}
	return obj.(*v1alpha1.DNSLock), nil
}
