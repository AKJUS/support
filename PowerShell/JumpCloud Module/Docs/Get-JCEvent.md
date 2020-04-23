---
external help file: JumpCloud-help.xml
Module Name: JumpCloud
online version: https://github.com/TheJumpCloud/support/wiki/Get-JCEvent
schema: 2.0.0
---

# Get-JCEvent

## SYNOPSIS
Query the API for Directory Insights events

## SYNTAX

### GetExpanded (Default)
```
Get-JCEvent [-EndTime <String>] [-Fields <String[]>] [-Limit <Int64>] [-SearchAfter <String[]>]
 [-SearchTermAnd <Hashtable>] [-SearchTermOr <Hashtable>] [-Service <String[]>] [-Sort <String>]
 [-StartTime <String>] [-Paginate <Boolean>] [<CommonParameters>]
```

### Get
```
Get-JCEvent -EventQueryBody <IEventQuery> [-Paginate <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
Query the API for Directory Insights events

## EXAMPLES

### EXAMPLE 1
```
(Get-JCEvent -Service:('all') -StartTime:('2020-04-15T00:00:00Z') -EndTime:('2020-04-16T23:00:00Z')).ToJsonString()| ConvertFrom-Json
```

Pull all event records between Tue, 14 Apr 2020 18:00:00 -0600 to Thu, 16 Apr 2020 17:00:00 -0600

### EXAMPLE 2
```
(Get-JCEvent -Service:('directory') -StartTime:('2020-04-15T00:00:00Z') -Limit:('10') -EndTime:('2020-04-16T23:00:00Z')).ToJsonString()| ConvertFrom-Json
```

Limit results to last 10 in the time range

### EXAMPLE 3
```
((Get-JCEvent -Service:('directory') -StartTime:('2020-04-15T00:00:00Z') -Sort:("DESC") -EndTime:('2020-04-16T23:00:00Z')).ToJsonString()| ConvertFrom-Json
```

Sort descending results against timestamp value

## PARAMETERS

### -EventQueryBody
EventQuery is the users' command to search our auth logs
Limit - row count (validated/repaired)
SearchTerm - see above
Projection - list of field names to return from document (not validated)
To construct, see NOTES section for EVENTQUERYBODY properties and create a hash table.

```yaml
Type: JumpCloud.SDK.DirectoryInsights.Models.IEventQuery
Parameter Sets: Get
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -EndTime
.

```yaml
Type: System.String
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Fields
.

```yaml
Type: System.String[]
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
.

```yaml
Type: System.Int64
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchAfter
.

```yaml
Type: System.String[]
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchTermAnd
.

```yaml
Type: System.Collections.Hashtable
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchTermOr
.

```yaml
Type: System.Collections.Hashtable
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Service
.

```yaml
Type: System.String[]
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sort
.

```yaml
Type: System.String
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartTime
.

```yaml
Type: System.String
Parameter Sets: GetExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Paginate
Set to $true to return all results.

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### JumpCloud.SDK.DirectoryInsights.Models.IEventQuery
## OUTPUTS

### JumpCloud.SDK.DirectoryInsights.Models.IGet200ApplicationJsonItemsItem
### System.String
## NOTES
COMPLEX PARAMETER PROPERTIES
To create the parameters described below, construct a hash table containing the appropriate properties.
For information on hash tables, run Get-Help about_Hash_Tables.

EVENTQUERYBODY \<IEventQuery\>: EventQuery is the users' command to search our auth logs         Limit - row count (validated/repaired)         SearchTerm - see above         Projection - list of field names to return from document (not validated)
  \[EndTime \<String\>\]: 
  \[Fields \<String\[\]\>\]: 
  \[Limit \<Int64?\>\]: 
  \[SearchAfter \<String\[\]\>\]: 
  \[SearchTermAnd \<ISearchTermAnd\>\]: 
    \[(Any) \<Object\>\]: This indicates any property can be added to this object.
  \[SearchTermOr \<ISearchTermOr\>\]: 
    \[(Any) \<Object\>\]: This indicates any property can be added to this object.
  \[Service \<String\[\]\>\]: 
  \[Sort \<String\>\]: 
  \[StartTime \<String\>\]:

## RELATED LINKS
