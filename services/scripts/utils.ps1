function Get-RunningContainers {
    docker ps --format "{{ .Names }}"
}
function Write-Section($section) {
    Write-Host "==================== $section ====================" -ForegroundColor Cyan

}