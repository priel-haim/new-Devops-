{{- define "interview-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "interview-app.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "interview-app.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


