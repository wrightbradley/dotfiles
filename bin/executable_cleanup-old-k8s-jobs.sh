#!/bin/bash

delete_jobs_older_than_7() {
	read -r namespace jobName dateTime <<<"$1"

	current_date=$(gdate +%s)
	date_seconds=$(gdate -d "$dateTime" +%s)
	diff_seconds=$((current_date - date_seconds))
	if ((diff_seconds > 604800)); then
		echo "Deleting $jobName. Too old."
		kubectl delete job $jobName -n $namespace
	else
		echo "Skipping $jobName. Too recent."
	fi

}

# Get Successfully Completed Jobs
export -f delete_jobs_older_than_7
kubectl get job --all-namespaces -o=jsonpath='{range .items[?(@.status.succeeded==1)]}{.metadata.namespace} {.metadata.name} {.status.completionTime} {"\n"}{end}' | xargs -I {} -P 4 bash -c 'delete_jobs_older_than_7 "$@"' _ {}
