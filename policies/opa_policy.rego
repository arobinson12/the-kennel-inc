package terraform.analysis

import input as tfplan

# Ensure all Compute Engine VMs have business_unit and approval_id labels
check_labels(resource) {
  labels := resource.change.after.labels
  labels.business_unit
  labels.approval_id
}

# Ensure no one has assigned Owner or Editor primitive roles to users or service accounts
check_roles(binding) {
  binding.role != "roles/owner"
  binding.role != "roles/editor"
}

authz {
  compute_instances := {resource | resource := tfplan.resource_changes[_]; resource.type == "google_compute_instance"; check_labels(resource)}

  role_bindings := {binding | binding := tfplan.resource_changes[_]; binding.type == "google_project_iam_binding"; check_roles(binding)}

  total_compute_instances := {resource | resource := tfplan.resource_changes[_]; resource.type == "google_compute_instance"}
  total_role_bindings := {binding | binding := tfplan.resource_changes[_]; binding.type == "google_project_iam_binding"}

  count(compute_instances) == count(total_compute_instances)
  count(role_bindings) == count(total_role_bindings)
}
