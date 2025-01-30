import json
import os

from huaweicloudsdkcore.auth.credentials import BasicCredentials
from huaweicloudsdkcore.region.region import Region
from rich import print
from rich.table import Table

from goad.exceptions import *
from goad.log import Log
from goad.provider.terraform.terraform import TerraformProvider
from goad.utils import *


class CloudruProvider(TerraformProvider):
    provider_name = CLOUDRU
    default_provisioner = PROVISIONING_REMOTE
    allowed_provisioners = [PROVISIONING_REMOTE]

    def __init__(self, lab_name, config):
        super().__init__(lab_name)
        self.resource_group = lab_name
        self.jumpbox_setup_script = 'setup_cloudru.sh'

    def __auth(self):
        AK = os.getenv('SBC_ACCESS_KEY')
        SK = os.getenv('SBC_SECRET_KEY')
        # TODO: dynamically get that endpoint and region
        iam = 'https://iam.ru-moscow-1.hc.sbercloud.ru/v3/'
        creds = BasicCredentials(AK, SK).with_iam_endpoint(iam)

        region = Region("ru-moscow-1", iam)

        return creds, region

    def check(self):
        # check terraform bin
        check = super().check()
        check_cloud = self.command.check_cloudru()
        check = check and check_cloud

        # TODO: fix, that API not supported by Cloud right now
        # creds, region = self.__auth()

        # client = StsClient.new_builder() \
        #     .with_credentials(creds) \
        #     .with_region(region) \
        #     .build()
        
        # request = GetCallerIdentityRequest()
        # print(client.get_caller_identity(request))

        return check

    def start(self):
        # TODO
        pass

    def stop(self):
        # TODO
        pass

    def status(self):
        # TODO
        pass

    def start_vm(self, vm_name):
        # TODO
        pass

    def stop_vm(self, vm_name):
        # TODO
        pass

    def destroy_vm(self, vm_name):
        # TODO
        pass

    def ssh_jumpbox(self):
        # TODO
        pass

    def get_jumpbox_ip(self, ip_range=''):
        jumpbox_ip = self.command.run_terraform_output(['ubuntu-jumpbox-ip'], self.path)
        if jumpbox_ip is None:
            Log.error('Jump box ip not found')
            return None
        if not Utils.is_valid_ipv4(jumpbox_ip):
            Log.error('Invalid IP')
            return None
        return jumpbox_ip
