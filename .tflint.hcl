tflint {
  required_version = "= 0.64.0"
}

config {
  call_module_type = "none"
}

# Bundled with TFLint: no external plugin or Azure credentials required.
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}
