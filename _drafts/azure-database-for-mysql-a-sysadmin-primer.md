# Azure DB for MySQL - a primer for confused sysadmins

I've recently been helping some folks with putting a platform on top of
Microsoft's Azure Cloud and this gave me my first opportunity to use MSFT's
cloudy managed MySQL service: Azure DB for MySQL. 

As someone who knows their way around both MySQL and the
surely-it's-pretty-comparable-? Amazon RDS service, I assumed a reasonable
level of IaaS and MySQL feature parity. This ... was a mistake! But not in a
hugely negative way ...

In this post, I'll document the things I *wish* I'd found clearly documented,
in a way which makes sense to both my sysadmin background and, possibly, yours
as well.

## Azure DB for MySQL is (at least a partly) shared service

https://docs.microsoft.com/en-us/azure/mysql/concepts-connectivity-architecture

https://azure.microsoft.com/en-gb/services/mysql/

## Your **username** 

https://dev.mysql.com/doc/internals/en/connection-phase-packets.html#packet-Protocol::HandshakeResponse

## Terraform's documentation doesn't say jack shit about this 

https://www.terraform.io/docs/providers/azurerm/r/mysql_server.html#administrator_login

## VNet Service Endpoints are **not** the same as AWS' VPC Interface Endpoints

## The documentation does a reasonable job of explaining (some) things

https://docs.microsoft.com/en-us/azure/mysql/concepts-data-access-and-security-vnet#terminology-and-description

