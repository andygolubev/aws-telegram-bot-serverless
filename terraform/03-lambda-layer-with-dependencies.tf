resource "null_resource" "pip-install" {
  provisioner "local-exec" {
    command = <<-EOF
      mkdir -p /tmp/packages/python/
      python3 -m venv /tmp/temp-venv
      source /tmp/temp-venv/bin/activate
      pip3 install -r ../lambda/bot-dependencies-layer/requirements.txt -t /tmp/packages/python/
      EOF
  }
}

data "archive_file" "layer-zip-file" {
  type = "zip"

  source_dir  = "/tmp/packages/"
  output_path = "/tmp/layer-package.zip"

  depends_on = [null_resource.pip-install, ]
}

resource "aws_lambda_layer_version" "lambda-layer-for-packages" {
  filename   = "/tmp/layer-package.zip"
  layer_name = "lambda-layer-for-packages"

  compatible_runtimes = ["python3.10"]

  depends_on = [data.archive_file.layer-zip-file, ]
}

