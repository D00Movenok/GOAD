# s7n.large.2 : 2 CPU / 4GB
# s7n.large.4 : 2CPU / 8GB
# s7n.xlarge.2 : 4 cpu / 8 GB
# s7n.xlarge.4 : 4 cpu / 16 GB
"dc01" = {
  name               = "dc01"
  os_image           = "Windows Server 2019 Datacenter 64bit English"
  private_ip_address = "{{ip_range}}.10"
  password           = "8dCT-DJjgScp"
  size               = "s7n.large.2"
}
"dc02" = {
  name               = "dc02"
  os_image           = "Windows Server 2019 Datacenter 64bit English"
  private_ip_address = "{{ip_range}}.11"
  password           = "NgtI75cKV+Pu"
  size               = "s7n.large.2"
}
"srv02" = {
  name               = "srv02"
  os_image           = "Windows Server 2019 Datacenter 64bit English"
  private_ip_address = "{{ip_range}}.22"
  password           = "NgtI75cKV+Pu"
  size               = "s7n.large.2"
}
