#!/usr/bin/python2.7

import boto3,json,re,sys,requests
from datetime import datetime,date

def listrec(R53C,ZID,RNAME):
    firstset=R53C.list_resource_record_sets(HostedZoneId=ZID, StartRecordName=RNAME, StartRecordType='A', MaxItems='1')['ResourceRecordSets'][0]
    #print firstset
    return firstset['Name'], firstset['ResourceRecords'][0]['Value'], firstset['Type']

def modrec(R53C,ZID,ACT,RNAME,TYPE,MYIP):
    R53C.change_resource_record_sets(
        HostedZoneId=ZID,
        ChangeBatch={
            'Changes': [
                {
                    'Action': ACT,
                    'ResourceRecordSet': {
                        'Name': RNAME,
                        'Type': TYPE,
                        'TTL': 123,
                        'ResourceRecords': [
                            {
                                'Value': MYIP
                            },
                        ]
                    }
                }
            ]
        }
    )

if len(sys.argv) == 3:
    rname=sys.argv[1]
    zoneid=sys.argv[2]
else:
    sys.exit('Usage: '+sys.argv[0]+' <subdomain> <zoneid>')

myip = requests.get('http://169.254.169.254/latest/meta-data/public-ipv4').text
r53c = boto3.client('route53',region_name='us-east-1')

# get current records:
currentname, currentvalue, currenttype = listrec(r53c,zoneid,rname)

# update/create:
if currentname == rname+'.':
    if currentvalue == myip:
        print 'IP is up to date ('+currentvalue+').'
    else:
        print 'Update IP from '+currentvalue+' to '+myip+' ...'
        modrec(r53c,zoneid,'UPSERT',rname,currenttype,myip)
else:
    print 'Record '+rname+' doesn\'t exist. Creating ...'
    modrec(r53c,zoneid,'CREATE',rname,currenttype,myip)

# verify change:
vername, vervalue, vertype = listrec(r53c,zoneid,rname)

if vername == rname+'.' and vervalue == myip and vertype == currenttype:
    print 'Verified'
else:
    sys.exit('RR create/upsert failed:\n\tSubdomain name: '+vername+'\n\tValue: '+vervalue+'\n\tRecord type: '+vertype)
