import requests

DEPLOY_URL          = "http://metadata.google.internal/computeMetadata/v1/instance" 
HEADERS             = { 'Metadata-Flavor': "Google" }  

#AWS Instance we need to use 'http://169.254.169.254/latest/'    
#curl "http://metadata.google.internal/computeMetadata/v1/instance"
# -H "Metadata-Flavor: Google"    
def get_metadata_items_list(): 
    try:     
        response            = requests.get(DEPLOY_URL, headers=HEADERS)
    except Exception as e:
        print(e) 
    return response.text      

def get_metadata_item_value(queryParam): 
    try: 
        URL                 = f"{DEPLOY_URL}/{queryParam}"
        response            = requests.get(URL, headers=HEADERS)
    except Exception as e:
        print(e) 
    return response.text      

def get_complete_metadata_json(metadataItems):
    completeData={}
    for item in metadataItems.split('\n'):
        if item != "" and '/' in item :
            queryParam          =   f"{item}?recursive=true&alt=json"
            completeData[item]  =   get_metadata_item_value(queryParam)
        elif item != "" :
            queryParam          =   f"{item}"
            completeData[item]  =   get_metadata_item_value(queryParam)
    return  completeData

def main():
    metadataItems   =   get_metadata_items_list()
    print(metadataItems)
    print("CompleteVMInstanceMetadatajson")
    key = input("Please give metadata item mentioned above as it is along with / if it mentioned above\n")
    if key == "CompleteVMInstanceMetadatajson" :
        print("Complete VM Instance Metadata in json format ",get_complete_metadata_json(metadataItems))
    elif key in metadataItems and '/' in key : 
        queryParam=f"{key}?recursive=true&alt=json"
        print("Instance metadata info ", key," is " ,get_metadata_item_value(queryParam))
    elif key in metadataItems :
        queryParam=f"{key}"
        print("Instance metadata info ", key," is " ,get_metadata_item_value(queryParam))
    

if __name__ == '__main__':
    main()
