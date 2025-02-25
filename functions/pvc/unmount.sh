#!/bin/bash


unmount_app_func(){
    ix_apps_pool=$(cli -c 'app kubernetes config' | 
                   grep -E "pool\s\|" | 
                   awk -F '|' '{print $3}' | 
                   sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    # Use mapfile command to read the output of cli command into an array
    mapfile -t pool_query < <(cli -m csv -c "storage pool query name,path" | sed -e '1d' -e '/^$/d')

    # Add an option for the boot directory
    pool_query+=("boot,/mnt")

    # Create an empty array to store the results
    unmount_array=()

    # Iterate through all available pools
    for line in "${pool_query[@]}"; do
        pool_path=$(echo "$line" | awk -F ',' '{print $2}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        # Check if the folder "mounted_pvc" exists in the current pool
        if [ -d "$pool_path/mounted_pvc" ]; then
            # If it exists, add the contents of the folder to the unmount_array
            mapfile -t unmount_array_temp < <(find "$pool_path/mounted_pvc" -mindepth 1 -maxdepth 1 -type d -printf '%f\n')
            unmount_array+=("${unmount_array_temp[@]}")
        fi
    done

    # Check if the unmount_array is empty
    if [[ -z ${unmount_array[*]} ]]; then
        echo -e "${yellow}There are no PVCS to unmount.${reset}"
        return
    fi

    for pvc_name in "${unmount_array[@]}"; do
        # Get the PVC details
        main=$(k3s kubectl get pvc --all-namespaces \
            --output="go-template={{range .items}}{{if eq .metadata.name \"$pvc_name\"}}\
            {{.metadata.namespace}} {{.metadata.name}} {{.spec.volumeName}}{{\"\n\"}}\
            {{end}}{{end}}")

        read -r app pvc_name pvc <<< "$main"
        app=${app:3}
        full_path="$ix_apps_pool/ix-applications/releases/$app/volumes"

        # Set the mountpoint to "legacy" and unmount
        if zfs set mountpoint=legacy "$full_path/$pvc"; then
            echo -e "${blue}$pvc_name ${green}unmounted successfully.${reset}"
            rmdir /mnt/*/mounted_pvc/"$pvc_name" 2>/dev/null || rmdir /mnt/mounted_pvc/"$pvc_name" 2>/dev/null
        else
            echo -e "${red}Failed to unmount ${blue}$pvc_name.${reset}"
            echo -e "${yellow}Please make sure your terminal is not open in the mounted directory${reset}"
        fi

    done

    # Remove the mounted_pvc directory if it's empty
    rmdir /mnt/*/mounted_pvc 2>/dev/null ; rmdir /mnt/mounted_pvc 2>/dev/null
}