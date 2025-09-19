{{- $total := 0 }}
{{- $critical := 0 }}
{{- $high := 0 }}
{{- $medium := 0 }}
{{- $low := 0 }}
{{- $image := "Unknown" }}
{{- $os := "Unknown" }}
{{- range . }}
  {{- if eq .Class "os-pkgs" -}}
    {{- $target := .Target }}
      {{- $image = $target | regexFind "[^\\s]+" }}
      {{- $os = $target | splitList "(" | last | trimSuffix ")" }}
  {{- end }}
  {{- range .Vulnerabilities }}
    {{- $total = add $total 1 }}
    {{- if  eq .Severity "CRITICAL" }}
      {{- $critical = add $critical 1 }}
    {{- end }}
    {{- if  eq .Severity "HIGH" }}
      {{- $high = add $high 1 }}
    {{- end }}
    {{- if  eq .Severity "MEDIUM" }}
      {{- $medium = add $medium 1 }}
    {{- end }}
    {{- if  eq .Severity "LOW" }}
      {{- $low = add $low 1 }}
    {{- end }}
  {{- end }}
{{- end }}
Vulnerability Summary for: {{ if ne $image "Unknown" }}{{ $image }}{{ else if ne $os "Unknown" }}{{ $os }}{{ else }}Not Found{{ end }}
=====================
Critical: {{ $critical }} | High: {{ $high }} | Medium: {{ $medium }} | Low: {{ $low }}
=====================
Total Vulnerabilities: {{ $total }}