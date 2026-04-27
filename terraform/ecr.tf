# 📦 Almacén de Imágenes (Docker Registry)
resource "aws_ecr_repository" "sre_repo" {
  name                 = "sre-chaos-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true # Para que sea fácil limpiar el lab después

  image_scanning_configuration {
    scan_on_push = true # SRE Best Practice: Escanear vulnerabilidades al subir
  }
}

# 📋 Salida: Necesitaremos la URL para subir nuestra imagen
output "ecr_repository_url" {
  value = aws_ecr_repository.sre_repo.repository_url
}
