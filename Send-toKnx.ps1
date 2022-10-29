<#
.SYNOPSIS
	Sends the passed details to KNX (albeit via Home Assistant).
.DESCRIPTION
	Pass a Group Address and Value to the script, and it will POST those as JSON to the provided URI
	
.NOTES
	Version				: 1.0
	Date				: 30th October 2022
	Author				: Greig Sheridan
	See the credits at the bottom of the script
	Blog post:  https://greiginsydney.com/streamdeck2knx
	WISH-LIST / TODO:
	KNOWN ISSUES:
	Revision History 	:
				v1.0 30th October 2022
					Initial release
				
					
.LINK
	https://greiginsydney.com/streamdeck2knx

.EXAMPLE
	.\Send-toKnx.ps1 -host "10.10.10.1" -webhook "send_knx_message" -group "1/0/1" -value "1"

	Description
	-----------
	Sends an ON command ('1') to group address '1/0/1' via the Home Assistant host "10.10.10.1" and webhook "send_knx_message".

.PARAMETER Host
	String. The IP address or hostname of your Home Assistant server.
.PARAMETER Webhook
	String. The webhook name that fires the Automation.
.PARAMETER Group
	String. Must be in the format "n/n/n"
.PARAMETER Value
	String. A number from 0 - 255
#>

[CmdletBinding(SupportsShouldProcess = $False)]
param(
	[parameter(ValueFromPipeline, ValueFromPipelineByPropertyName = $true, Mandatory= $true)]
	[alias('host')][string]$hostname,
	
	[parameter(ValueFromPipeline, ValueFromPipelineByPropertyName = $true, Mandatory= $true)]
	[string]$webhook,
	
	[Parameter(Mandatory = $true)]
	[ValidateScript({$_ -match "^\d{1,3}\/\d\/\d{1,3}$"})]	# Must be in "1/1/1" format
	[string]$group,
	
	[Parameter(Mandatory = $true)]
	[ValidateScript({$_ -match "^([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])$"})]	# Must be numerals from 0 - 255
	[string]$value
)

$Error.Clear()		#Clear PowerShell's error variable
$Global:Debug = $psboundparameters.debug.ispresent

# Format: http://10.10.10.1:8123/api/webhook/send_knx_message

$hostname = $hostname.trim()
$hostname = [regex]::replace($hostname, 'https?://' , '') #Remove any 'httpx' header if present

$webhook = $webhook.trim()
$uri = $hostname + ":8123/api/webhook/" + $webhook

$params = @{"group" = $group; "value" = $value}

Invoke-WebRequest -Uri $uri -Method POST -Body ($params|ConvertTo-Json) -ContentType "application/json"

# No, you don't need a script, you could just send this from the command line:
# Invoke-WebRequest -Uri "http://<IP>:8123/api/webhook/send_knx_message" -Method POST -Body (@{"group" = "1/0/1"; "value" = "1"}|ConvertTo-Json) -ContentType "application/json"
