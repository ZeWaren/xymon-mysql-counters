xymon-mysql-counters
====================
xymon-mysql-counters is a perl script that you can use to monitor a bunch of status variable from a mysql installation and graph them into your BB/Hobbit/Xymon server.

![A xymon page featuring some mysql counters](https://raw.github.com/ZeWaren/xymon-mysql-counters/master/exemple_graphs/xymon_page.png "A xymon page featuring some mysql counters")

How it works
------------

`xymon_mysql_counters.pl` connects to your mysql server and issues the following queries to get the needed data:

+ `SELECT * FROM INFORMATION_SCHEMA.GLOBAL_STATUS`
+ `SELECT VARIABLE_NAME, VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_VARIABLES WHERE VARIABLE_NAME IN ('MAX_CONNECTIONS', 'QUERY_CACHE_SIZE', 'TABLE_OPEN_CACHE')`

The values are then posted into the host's trends data channel.

Some HTML code is also posted as a status, in order to be able to see the graphs alone on one page (ugly but works). If you only want the graphs to appear in the trends page, you can remove the line that send the status and then set the `TRENDS` variable in `xymonserver.cfg`.

Installation
------------
+ Copy `xymon_mysql_counters.pl` somewhere executable by your xymon client (typically `$HOBBITCLIENTHOME/ext` or `$XYMONCLIENTHOME/ext`). Set the permissions accordingly.
 

+ Edit the script to provide your mysql credentials.
```
use constant DBI_URN => 'DBI:mysql:information_schema';
use constant DBI_USERNAME => 'xymon';
use constant DBI_PASSWORD => 'mysuperstrongpassword';
```
See [DBD::mysql on CPAN](http://search.cpan.org/~capttofu/DBD-mysql-4.022/lib/DBD/mysql.pm) for more information about the URN string.

+ Makes xymon execute the script periodically.
In `hobbitlaunch.cfg` (Hobbit)
```
[mysql]
    ENVFILE $HOBBITCLIENTHOME/etc/hobbitclient.cfg
    CMD $HOBBITCLIENTHOME/ext/xymon_mysql_counters.pl
    LOGFILE $HOBBITCLIENTHOME/logs/hobbit-mysql.log
    INTERVAL 2m
```
or in `clientlaunch.cfg` (Xymon)
```
[mysql]
    ENVFILE $XYMONCLIENTHOME/etc/xymonclient.cfg
    CMD $XYMONCLIENTHOME/ext/xymon_mysql_counters.pl
    LOGFILE $XYMONCLIENTLOGS/xymon-mysql.log
    INTERVAL 2m
```

+ Append or include the provided file to `graphs.cfg`.

+ Restart xymon-client.

Sample graphs:
--------------

![MySQL Activity](https://raw.github.com/ZeWaren/xymon-mysql-counters/master/exemple_graphs/mysql_activity.png "MySQL Activity")

![MySQL Command Counters](https://raw.github.com/ZeWaren/xymon-mysql-counters/master/exemple_graphs/mysql_command_counters.png "MySQL Command Counters")

![MySQL Connections](https://raw.github.com/ZeWaren/xymon-mysql-counters/master/exemple_graphs/mysql_connections.png "MySQL Connections")

![MySQL Handlers](https://raw.github.com/ZeWaren/xymon-mysql-counters/master/exemple_graphs/mysql_handlers.png "MySQL Handlers")

![MySQL Query Cache](https://raw.github.com/ZeWaren/xymon-mysql-counters/master/exemple_graphs/mysql_query_cache.png "Query Cache")

![MySQL Select Types](https://raw.github.com/ZeWaren/xymon-mysql-counters/master/exemple_graphs/mysql_select_types.png "Select Types")

![MySQL Sorts](https://raw.github.com/ZeWaren/xymon-mysql-counters/master/exemple_graphs/mysql_sorts.png "MySQL Sorts")

![MySQL Table Locks](https://raw.github.com/ZeWaren/xymon-mysql-counters/master/exemple_graphs/mysql_table_locks.png "Table Locks")

![MySQL Temporary Objects](https://raw.github.com/ZeWaren/xymon-mysql-counters/master/exemple_graphs/mysql_temporary_objects.png "Temporary Objects")

![MySQL Transaction Handlers](https://raw.github.com/ZeWaren/xymon-mysql-counters/master/exemple_graphs/mysql_transaction_handlers.png "MySQL Transaction Handlers")

![MySQL Prepared Statements](https://raw.github.com/ZeWaren/xymon-mysql-counters/master/exemple_graphs/mysql_prepared_statements.png "MySQL Prepared Statements")

Credits:
--------

xymon-mysq-counters was written in October 2012 by: ZeWaren / Erwan Martin <<public@fzwte.net>>.

It is licensed under the MIT License.

This code is strongly inspired from the [Percona MySQL Monitoring Template for Cacti](http://www.percona.com/doc/percona-monitoring-plugins/cacti/mysql-templates.html). The credits for the MySQL part should go to these guys.

