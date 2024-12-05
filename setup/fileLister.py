import json, os, re

raise Exception("running this will fuck up 'prgmFiles.json', but it's not worth deleting")

with open("./setup/prgmFiles.json","r+") as json_file:
    fileLocations = json.load(json_file)
    fileLocations['files'] = []

    for directory in fileLocations['directories']:

        dir_path = f'./{directory}'
        print(f'walking {dir_path}')
        for root, dirs, files in os.walk(dir_path):

            for file_name in files:
                has_criteria = directory in fileLocations['criteria']
                if (has_criteria and re.search( fileLocations["criteria"][directory], file_name ) ) or not has_criteria:
                    file_path = f'{directory}/{file_name}'
                    fileLocations['files'].append(file_path)
                    print(f'added {file_path}')

    print('added all files to list')

    json_file.truncate(0)
    print("truncated json file")
    json.dump(fileLocations, json_file)
    print("stored new data too file")
print("finished succesfully")