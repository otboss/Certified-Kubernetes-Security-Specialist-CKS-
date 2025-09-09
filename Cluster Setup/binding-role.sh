#!/bin/sh
k3s kubectl create rolebinding pod-reader-binding \
  --role=pod-reader \
  --serviceaccount=secure-ns:secure-sa \
  -n secure-ns