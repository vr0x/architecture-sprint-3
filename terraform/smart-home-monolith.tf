resource "helm_release" "smart-home-monolith" {
  name       = "smart-home-monolith"
  namespace  = "default"
  chart      = "../charts/smart-home-monolith"
  timeout    = 6000  # Увеличиваем таймаут до 10 минут
}