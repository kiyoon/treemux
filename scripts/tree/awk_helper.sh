#!/usr/bin/env bash

# ps -el | awk_by_name '{print $(f["PID"])}'
awk_by_name() {
	awk '
	{
		for (i = 1; i <= NF; i++) {
			f[$i] = i;
		}
	} '"$1"
}
