Here’s a **clear summary** of the “Cluster Hardening – Service Accounts” guidance from the CKS (Certified Kubernetes Security Specialist) exam domain:

---

### 🔑 Goal

**Limit and carefully manage Service Accounts** so pods don’t get unnecessary access to the Kubernetes API. This prevents privilege escalation if a pod is compromised.

---

### 📝 Summary of Best Practices

1. **Don’t rely on the default ServiceAccount**

   * Every namespace automatically has a ServiceAccount named `default`.
   * By default, pods without a `serviceAccountName` use it.
   * This can accidentally grant pods API access they don’t need.

   ✅ **Action:** In your pod specs always set

   ```yaml
   automountServiceAccountToken: false
   ```

   unless the pod really needs API access.

---

2. **Disable automatic mounting of tokens by default**

   * ServiceAccount tokens are mounted as files inside pods automatically.
   * Turn off token mounting on the ServiceAccount or the Pod spec if it’s not needed:

   ```yaml
   automountServiceAccountToken: false
   ```

---

3. **Create dedicated Service Accounts per workload**

   * Instead of using the `default` ServiceAccount for many pods, create **one ServiceAccount per app/workload**.
   * This makes it easy to give just the permissions needed.

---

4. **Minimize RBAC permissions**

   * Start with no permissions.
   * Grant only the exact verbs/resources needed (`get`, `list`, `watch`, etc.).
   * Use Roles (namespace scope) and RoleBindings (bind to ServiceAccounts) rather than ClusterRoles unless cluster-wide access is truly required.

---

5. **Rotate or revoke tokens**

   * If a pod no longer needs access, remove or rotate the ServiceAccount or RoleBinding.
   * In newer Kubernetes versions, ServiceAccount tokens are short-lived by default — leverage that.

---

6. **Audit & Monitor**

   * Regularly review ServiceAccounts and RBAC bindings.
   * Remove stale ServiceAccounts or excessive privileges.

---

### ✅ Takeaway

> **Never give pods more API access than they strictly need.**
> Use dedicated ServiceAccounts, disable default token mounting, and bind the least-privileged Roles. This dramatically reduces the blast radius if a pod is compromised.

---

Would you like me to make a **quick checklist** you can memorize for the CKS exam about ServiceAccounts? (handy for studying).
