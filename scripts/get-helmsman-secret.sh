#!/bin/bash

#!/bin/bash

sa_name="helmsman"
SERVER_URL=`kubectl config view --minify -o jsonpath="{.clusters[0].cluster.server}"`
SA_SECRET_NAME=`kubectl get serviceAccounts $sa_name -o=jsonpath="{.secrets[*].name}"`

if [[ "$SA_SECRET_NAME" == "" ]]; then
    printf '%s\n' "No secret found for service account: $sa_name" >&2
else
    secret=$(kubectl get secret $SA_SECRET_NAME -o json)
    printf '%s\n%s\n%s\n' "CLUSTER URI: $SERVER_URL" "SA SECRET:" "$secret" >&2
fi
