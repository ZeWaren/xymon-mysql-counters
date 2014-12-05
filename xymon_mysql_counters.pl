#!/usr/bin/perl -w

use strict;
use warnings;

use DBI;
use DBD::mysql;
use Sys::Hostname;

use constant DBI_URN => 'DBI:mysql:information_schema';
use constant DBI_USERNAME => 'xymon_user';
use constant DBI_PASSWORD => 'password';

use constant XYMON_WWW_ROOT => '';
sub get_graph_html {
        my ($host, $service) = @_;
        '<table summary="'.$service.' Graph"><tr><td><A HREF="'.XYMON_WWW_ROOT.'/xymon-cgi/showgraph.sh?host='.$host.'&amp;service='.$service.'&amp;graph_width=576&amp;graph_height=120&amp;first=1&amp;count=1&amp;disp='.$host.'&amp;action=menu"><IMG BORDER=0 SRC="'.XYMON_WWW_ROOT.'/xymon-cgi/showgraph.sh?host='.$host.'&amp;service='.$service.'&amp;graph_width=576&amp;graph_height=120&amp;first=1&amp;count=1&amp;disp='.$host.'&amp;graph=hourly&amp;action=view" ALT="xymongraph '.$service.'"></A></td><td align="left" valign="top"><a href="'.XYMON_WWW_ROOT.'/xymon-cgi/showgraph.sh?host='.$host.'&amp;service='.$service.'&amp;graph_width=576&amp;graph_height=120&amp;first=1&amp;count=1&amp;disp='.$host.'&amp;graph_start=1350474056&amp;graph_end=1350646856&amp;graph=custom&amp;action=selzoom"><img src="'.XYMON_WWW_ROOT.'/xymon/gifs/zoom.gif" border=0 alt="Zoom graph" style=\'padding: 3px\'></a></td></tr></table>';
}

my $dbh = DBI->connect(DBI_URN, DBI_USERNAME, DBI_PASSWORD) or die($DBI::errstr);

my $sth = $dbh->prepare("SELECT * FROM INFORMATION_SCHEMA.GLOBAL_STATUS");
$sth->execute( ) or die($DBI::errstr);
my $values = {};
while ( my @row = $sth->fetchrow_array ) {
    $values->{$row[0]} = $row[1];
}

$sth = $dbh->prepare("SELECT VARIABLE_NAME, VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_VARIABLES WHERE VARIABLE_NAME IN ('MAX_CONNECTIONS', 'QUERY_CACHE_SIZE', 'TABLE_OPEN_CACHE')");
$sth->execute( ) or die($DBI::errstr);
while ( my @row = $sth->fetchrow_array ) {
    $values->{$row[0]} = $row[1];
}

my $trends = "
[mysql_activity.rrd]
DS:sel:DERIVE:600:0:U ".$values->{COM_SELECT}."
DS:ins:DERIVE:600:0:U ".$values->{COM_INSERT}."
DS:upd:DERIVE:600:0:U ".$values->{COM_UPDATE}."
DS:rep:DERIVE:600:0:U ".$values->{COM_REPLACE}."
DS:del:DERIVE:600:0:U ".$values->{COM_DELETE}."
DS:cal:DERIVE:600:0:U ".$values->{COM_CALL_PROCEDURE}."
[mysql_connections.rrd]
DS:max_connections:GAUGE:600:0:U ".$values->{MAX_CONNECTIONS}."
DS:max_used:GAUGE:600:0:U ".$values->{MAX_USED_CONNECTIONS}."
DS:aborted_clients:DERIVE:600:0:U ".$values->{ABORTED_CLIENTS}."
DS:aborted_connects:DERIVE:600:0:U ".$values->{ABORTED_CONNECTS}."
DS:threads_connected:GAUGE:600:0:U ".$values->{THREADS_CONNECTED}."
DS:threads_running:GAUGE:600:0:U ".$values->{THREADS_RUNNING}."
DS:new_connections:DERIVE:600:0:U ".$values->{CONNECTIONS}."
[mysql_command_counters.rrd]
DS:questions:DERIVE:600:0:U ".$values->{QUESTIONS}."
DS:select:DERIVE:600:0:U ".$values->{COM_SELECT}."
DS:delete:DERIVE:600:0:U ".$values->{COM_DELETE}."
DS:insert:DERIVE:600:0:U ".$values->{COM_INSERT}."
DS:update:DERIVE:600:0:U ".$values->{COM_UPDATE}."
DS:replace:DERIVE:600:0:U ".$values->{COM_REPLACE}."
DS:load:DERIVE:600:0:U ".$values->{COM_LOAD}."
DS:delete_multi:DERIVE:600:0:U ".$values->{COM_DELETE_MULTI}."
DS:insert_select:DERIVE:600:0:U ".$values->{COM_INSERT_SELECT}."
DS:update_multi:DERIVE:600:0:U ".$values->{COM_UPDATE_MULTI}."
DS:replace_select:DERIVE:600:0:U ".$values->{COM_REPLACE_SELECT}."
[mysql_files_and_tables.rrd]
DS:table_open_cache:GAUGE:600:0:U ".$values->{TABLE_OPEN_CACHE}."
DS:open_tables:GAUGE:600:0:U ".$values->{OPEN_TABLES}."
DS:opened_files:DERIVE:600:0:U ".$values->{OPENED_FILES}."
DS:opened_tables:DERIVE:600:0:U ".$values->{OPENED_TABLES}."
[mysql_handlers.rrd]
DS:write:DERIVE:600:0:U ".$values->{HANDLER_WRITE}."
DS:update:DERIVE:600:0:U ".$values->{HANDLER_UPDATE}."
DS:delete:DERIVE:600:0:U ".$values->{HANDLER_DELETE}."
DS:read_first:DERIVE:600:0:U ".$values->{HANDLER_READ_FIRST}."
DS:read_key:DERIVE:600:0:U ".$values->{HANDLER_READ_KEY}."
DS:read_next:DERIVE:600:0:U ".$values->{HANDLER_READ_NEXT}."
DS:read_prev:DERIVE:600:0:U ".$values->{HANDLER_READ_PREV}."
DS:read_rnd:DERIVE:600:0:U ".$values->{HANDLER_READ_RND}."
DS:read_rnd_next:DERIVE:600:0:U ".$values->{HANDLER_READ_RND_NEXT}."
[mysql_query_cache.rrd]
DS:queries_in_cache:DERIVE:600:0:U ".$values->{QCACHE_QUERIES_IN_CACHE}."
DS:hits:DERIVE:600:0:U ".$values->{QCACHE_HITS}."
DS:inserts:DERIVE:600:0:U ".$values->{QCACHE_INSERTS}."
DS:not_cached:DERIVE:600:0:U ".$values->{QCACHE_NOT_CACHED}."
DS:lowmem_prunes:DERIVE:600:0:U ".$values->{QCACHE_LOWMEM_PRUNES}."
[mysql_prepared_statements.rrd]
DS:stmt_count:GAUGE:600:0:U ".$values->{PREPARED_STMT_COUNT}."
[mysql_select_types.rrd]
DS:full_join:DERIVE:600:0:U ".$values->{SELECT_FULL_JOIN}."
DS:full_range_join:DERIVE:600:0:U ".$values->{SELECT_FULL_RANGE_JOIN}."
DS:range:DERIVE:600:0:U ".$values->{SELECT_RANGE}."
DS:range_check:DERIVE:600:0:U ".$values->{SELECT_RANGE_CHECK}."
DS:scan:DERIVE:600:0:U ".$values->{SELECT_SCAN}."
[mysql_sorts.rrd]
DS:sort_rows:DERIVE:600:0:U ".$values->{SORT_ROWS}."
DS:sort_range:DERIVE:600:0:U ".$values->{SORT_RANGE}."
DS:sort_merge_passes:DERIVE:600:0:U ".$values->{SORT_MERGE_PASSES}."
DS:sort_scan:DERIVE:600:0:U ".$values->{SORT_SCAN}."
[mysql_table_locks.rrd]
DS:immediate:DERIVE:600:0:U ".$values->{TABLE_LOCKS_IMMEDIATE}."
DS:waited:DERIVE:600:0:U ".$values->{TABLE_LOCKS_WAITED}."
[mysql_temp_objects.rrd]
DS:tables:DERIVE:600:0:U ".$values->{CREATED_TMP_TABLES}."
DS:tmp_disk_tables:DERIVE:600:0:U ".$values->{CREATED_TMP_DISK_TABLES}."
DS:tmp_files:DERIVE:600:0:U ".$values->{CREATED_TMP_FILES}."
[mysql_transaction_handlers.rrd]
DS:commit:DERIVE:600:0:U ".$values->{HANDLER_COMMIT}."
DS:rollback:DERIVE:600:0:U ".$values->{HANDLER_ROLLBACK}."
DS:savepoint:DERIVE:600:0:U ".$values->{HANDLER_SAVEPOINT}."
DS:savepoint_rollback:DERIVE:600:0:U ".$values->{HANDLER_SAVEPOINT_ROLLBACK}."
";


my $host = $ENV{MACHINEDOTS};
my $report_date = `/bin/date`;
my $color = 'clear';
my $service = 'mysql';

my $data = "
<h2>Status</h2>
No status checked

<h2>Counters</h2>
".get_graph_html($host, 'mysql_activity')."
".get_graph_html($host, 'mysql_command_counters')."
".get_graph_html($host, 'mysql_connections')."
".get_graph_html($host, 'mysql_files_and_tables')."
".get_graph_html($host, 'mysql_handlers')."
".get_graph_html($host, 'mysql_query_cache')."
".get_graph_html($host, 'mysql_select_types')."
".get_graph_html($host, 'mysql_sorts')."
".get_graph_html($host, 'mysql_table_locks')."
".get_graph_html($host, 'mysql_temp_objects')."
".get_graph_html($host, 'mysql_transaction_handlers')."
".get_graph_html($host, 'mysql_prepared_statements')."

";

system( ("$ENV{BB}", "$ENV{BBDISP}", "status $host.$service $color $report_date$data\n") );
system( "$ENV{BB} $ENV{BBDISP} 'data $host.trends $trends'\n");
