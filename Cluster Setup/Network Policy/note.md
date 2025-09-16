# Network Policy
Sure — let’s go deep. 🔥  
Network Policies in Kubernetes are one of the key security primitives for controlling **traffic flow between pods** and **traffic to/from outside the cluster**.

* * *

🔹 1. What a NetworkPolicy Is
-----------------------------

A **NetworkPolicy** is a Kubernetes resource (like a Pod or Service) that defines **how pods can communicate** with each other and with other network endpoints.  
Think of it as **firewall rules at the pod level**.

It uses **labels** to select the pods it applies to, and rules to define **allowed ingress and/or egress traffic**.

* * *

🔹 2. Key Concepts
------------------

### Pod Selector

*   Specifies **which pods** the policy applies to.
*   Uses label selectors:
    
    ```text-plain
    podSelector:
      matchLabels:
        role: frontend
    ```
    
*   Empty `{}` means it applies to **all pods** in the namespace.

### Policy Types

*   **Ingress** – incoming traffic to the selected pods.
*   **Egress** – outgoing traffic from the selected pods.

### Rules

*   **from** (for ingress): who can send to the pod.
*   **to** (for egress): who the pod can send to.
*   **ports**: which ports are allowed.

### Default Deny

*   By default, pods accept all traffic.
*   A pod becomes **isolated** for ingress or egress once **any** policy selecting it exists for that direction.
*   After that, only what’s explicitly allowed will flow.

* * *

🔹 3. Anatomy of a NetworkPolicy
--------------------------------

Example: allow incoming traffic on port 80 from pods with label `app: backend` to pods labeled `app: frontend`:

```text-plain
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-to-frontend
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 80
```

* * *

### Key Takeaways:

*   **policyTypes:** You must list Ingress, Egress, or both.
*   **Ingress section:** “who can talk to me.”
*   **Egress section:** “who I can talk to.”

* * *

🔹 4. Ingress vs Egress
-----------------------

*   **Ingress Policy** → controls incoming traffic **to** selected pods.
*   **Egress Policy** → controls outgoing traffic **from** selected pods.

Example of egress:

```text-plain
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-egress
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          env: prod
    ports:
    - protocol: TCP
      port: 443
```

This allows pods with `app: frontend` to talk only to pods in namespaces labeled `env: prod` on port 443.

* * *

🔹 5. How They’re Enforced
--------------------------

*   **Kubernetes itself does not enforce NetworkPolicies.**
*   Enforcement depends on the **CNI plugin** (Calico, Cilium, Weave Net, etc.).
*   If your cluster uses a CNI that does not support NetworkPolicies (like the basic bridge plugin), your policies won’t take effect.

* * *

🔹 6. Common Patterns
---------------------

### a. Default deny all ingress for a namespace:

```text-plain
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: my-namespace
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

### b. Allow traffic from the same namespace:

```text-plain
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-namespace
  namespace: my-namespace
spec:
  podSelector: {}
  ingress:
  - from:
    - podSelector: {}
```

### c. Allow DNS (important for egress):

```text-plain
egress:
- to:
  - namespaceSelector:
      matchLabels:
        kube-system: "true"
    podSelector:
      matchLabels:
        k8s-app: kube-dns
  ports:
  - protocol: UDP
    port: 53
```

* * *

🔹 7. Best Practices
--------------------

1.  **Start with Default Deny**
    *   Create a default deny for ingress and egress in each namespace.
    *   Then explicitly allow needed communications.
2.  **Use Namespaces for Isolation**
    *   Combine `namespaceSelector` with `podSelector` for fine-grained rules.
3.  **Be Mindful of DNS and External Access**
    *   Pods often need DNS access and sometimes outbound HTTPS. Allow them explicitly.
4.  **Test Policies in Staging**
    *   A misconfigured policy can block all traffic.
5.  **Leverage CNI Features**
    *   Plugins like Calico support more advanced features (global policies, FQDN policies, etc.).

* * *

🔹 8. Visual Model
------------------

Think of it as a firewall **at each pod’s network interface**.  
When no NetworkPolicy exists → “ALLOW ALL.”  
Once one is created → “DENY BY DEFAULT except what’s allowed.”

* * *

🔹 9. Debugging Tips
--------------------

*   Check which pods a policy selects:
    
    ```text-plain
    kubectl get pods -l app=frontend -n my-namespace
    ```
    
*   Use network policy viewers like **kubectl-neat** or **kubectl-np-viewer** to visualize flows.
*   Temporarily use `curl` or `netcat` between pods to test connectivity.

* * *

✅ **In summary:**

*   Network Policies = Kubernetes firewall at the pod level.
*   Use labels + selectors to define which pods can talk to which pods and on which ports.
*   Always ensure your CNI plugin supports NetworkPolicies.
*   Start restrictive, then open up what’s needed.

* * *

Would you like me to draw a **diagram** showing how pods + NetworkPolicies interact (a visual flow)? (It helps a lot.)