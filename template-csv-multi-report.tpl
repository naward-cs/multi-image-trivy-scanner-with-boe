{{- $image := "Unknown" }}
{{- $os := "Unknown" }}
{{- range . }}
  {{- if eq .Class "os-pkgs" -}}
    {{- $target := .Target }}
      {{- $image = $target | regexFind "[^\\s]+" }}
      {{- $os = $target | splitList "(" | last | trimSuffix ")" }}
  {{- end }}
  {{- $target := .Target }}
  {{- range .Vulnerabilities }}
"{{ if ne $image "Unknown" }}{{ $image }}{{ else if ne $os "Unknown" }}{{ $os }}{{ else }}Not Found{{ end }}", "{{ js $target }}","{{ js .VulnerabilityID }}","{{ js .Severity }}","{{ js .PkgName }}","{{ js .InstalledVersion }}","{{ js .FixedVersion }}","{{ js .Title }}","{{ js .Description }}"
  {{- end }}
{{- end }}