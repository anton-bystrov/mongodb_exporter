local grafana = import 'github.com/grafana/grafonnet-lib/grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local prometheus = grafana.prometheus;
local template = grafana.template;
local graphPanel = grafana.graphPanel;

local c = import '../config.libsonnet';





local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local graphPanel = grafana.graphPanel;
local annotation = grafana.annotation;
local text = grafana.text;
local template = grafana.template;
local timepicker = grafana.timepicker;
local prometheus = grafana.prometheus;
local row = grafana.row;
local singlestat = grafana.singlestat;
local tablePanel = grafana.tablePanel;


dashboard.new(
  'MongoDB Instance Summary',
  time_from='now-12h',
  editable=false,
  refresh= "1m",
  graphTooltip='shared_crosshair',
  schemaVersion=18,
  version=1,
  tags=[ "MongoDB","Percona"],
  iteration=1553588305920,
  uid="6Lk9wMHik",
  timepicker = timepicker.new(
    hidden = false,
    now=true,
    )
)
.addAnnotation(
  grafana.annotation.datasource(
    'PMM Annotations',
    '-- Grafana --',
    enable=true,
    hide=false,
    type='tags',
    builtIn=1,
    iconColor='#e0752d',
    limit=100,
    tags = [ "pmm_annotation",
            "$host",
            "$service"],
  )
)
.addAnnotation(
  grafana.annotation.datasource(
    'Annotations & Alerts',
    '-- Grafana --',
    enable=true,
    hide=true,
    type='dashboard',
    builtIn=1,
    iconColor='#6ed0e0',
    limit=100,
  )
)
.addLink(
  grafana.link.dashboards(
    'Query Analytics',
    ['QAN'],
    type='link',
    url='/graph/d/7w6Q3PJmz/pmm-query-analytics',
    keepTime=true,
    includeVars=true,
    asDropdown=false,
    icon='dashboard',
  )
)
.addLink(
  grafana.link.dashboards(
    'OS',
    ['OS'],
    keepTime=true,
    includeVars=true,
  )
)
.addLink(
  grafana.link.dashboards(
    'MySQL',
    ['MySQL'],
    keepTime=true,
    includeVars=true,
  )
)
.addLink(
  grafana.link.dashboards(
    'MongoDB',
    ['MongoDB'],
    keepTime=true,
    includeVars=true,
  )
)
.addLink(
  grafana.link.dashboards(
    'PostgreSQL',
    ['PostgreSQL'],
    keepTime=true,
    includeVars=true,
  )
)
.addLink(
  grafana.link.dashboards(
    'HA',
    ['HA'],
    keepTime=true,
    includeVars=true,
  )
)
.addLink(
  grafana.link.dashboards(
    'Insight',
    ['Insight'],
    keepTime=true,
    includeVars=true,
  )
)
.addLink(
  grafana.link.dashboards(
    'PMM',
    ['PMM'],
    keepTime=true,
    includeVars=true,
  )
)
.addTemplate(
    template.interval('interval', 'auto,1s,5s,1m,5m,1h,6h,1d', 'auto', label='Interval', auto_count=200, auto_min='1s'),
)
.addTemplate(
  template.new(
  'cluster',
  'Prometheus',
  'label_values(mongodb_up,cluster)',
  label='Cluster',
  refresh='load',
  sort=1,
  allFormat='blob',
  multiFormat='glob',
  multi=false,
  skipUrlSync=false,
  includeAll=true,
  ),
)
.addTemplate(
  template.new(
  'host',
  'Prometheus',
  'label_values(mongodb_up{cluster=~"$cluster"}, node_name)',
  label='Host',
  refresh='load',
  sort=1,
  allFormat='glob',
  multiFormat='glob',
  multi=false,
  skipUrlSync=false,
  includeAll=true,
  ),
)
.addTemplate(
  template.new(
  'service',
  'Prometheus',
  'label_values(mongodb_up{cluster=~"$cluster",node_name=~"$host"}, service_name)',
  label='Service',
  refresh='load',
  sort=1,
  allFormat='glob',
  multiFormat='glob',
  multi=false,
  skipUrlSync=false,
  includeAll=false,
  ),
)
.addPanel(
  graphPanel.new(
    'Command Operations',//title
    description='Shows the average number of commands per second that have been run during the selected interval. These commands are broken out by type such as `insert`, `delete`, `update`, etc. On a secondary node, this will show the number of replicated commands.',
    fill=2,
    linewidth=2,
    decimals=1,
    datasource='Prometheus',
    pointradius=5,
    paceLength=10,
    legend_values=true,
    legend_min=true,
    legend_max=true,
    legend_avg=true,
    legend_alignAsTable=true,
    legend_rightSide=true,
    legend_hideZero=false,
    legend_show=true,
    legend_sortDesc=true,
    legend_sort='avg',
    editable=true,
    formatY1='ops',
    minY1=0,
  )
  .addTarget(
      prometheus.target(
        'rate(mongodb_mongod_op_counters_total{service_name="$service", type!="command"}[$interval]) or
        irate(mongodb_mongod_op_counters_total{service_name="$service", type!="command"}[5m]) or
        rate(mongodb_mongos_op_counters_total{service_name="$service", type!="command"}[$interval]) or
        irate(mongodb_mongos_op_counters_total{service_name="$service", type!="command"}[5m])',
        refId='J',
        interval='$interval',
        step=300,
        intervalFactor=1,
        legendFormat='{{type}}',
      )
  )
  .addTarget(
      prometheus.target(
        'rate(mongodb_mongod_op_counters_repl_total{service_name="$service", type!~"(command|query|getmore)"}[$interval]) or
        irate(mongodb_mongod_op_counters_repl_total{service_name="$service", type!~"(command|query|getmore)"}[5m]) or
        rate(mongodb_mongos_op_counters_repl_total{service_name="$service", type!~"(command|query|getmore)"}[$interval]) or
        irate(mongodb_mongos_op_counters_repl_total{service_name="$service", type!~"(command|query|getmore)"}[5m])',
        refId='A',
        interval='$interval',
        step=300,
        legendFormat='repl_{{type}}',
        intervalFactor=1,
      )
  )
  .addTarget(
      prometheus.target(
        'rate(mongodb_mongod_metrics_ttl_deleted_documents_total{service_name="$service"}[$interval]) or
        irate(mongodb_mongod_metrics_ttl_deleted_documents_total{service_name="$service"}[5m]) or
        rate(mongodb_mongos_metrics_ttl_deleted_documents_total{service_name="$service"}[$interval]) or
        irate(mongodb_mongos_metrics_ttl_deleted_documents_total{service_name="$service"}[5m])',
        refId='B',
        interval='$interval',
        step=300,
        legendFormat='ttl_delete',
        intervalFactor=1,
      )
  ),
  gridPos={
    "h": 7,
    "w": 24,
    "x": 0,
    "y": 0,
  },
  style=null,
)//15 graph
.addPanel(
  graphPanel.new(
    'Connections',//title
    description='This shows the number of active connections on the server. Keep in mind the hard limit on the maximum number of connections set by your distribution.\n\nYou can read more about the [connection numbers](https://docs.mongodb.com/manual/administration/analyzing-mongodb-performance/#number-of-connections).',
    fill=2,
    linewidth=2,
    datasource='Prometheus',
    height='250px',
    pointradius=5,
    paceLength=10,
    legend_values=true,
    legend_min=true,
    legend_max=true,
    legend_avg=true,
    legend_alignAsTable=true,
    legend_show=true,
    legend_sortDesc=true,
    legend_sort='avg',
    editable=true,
    value_type='cumulative',
    minY1=0,
  )
  .addTarget(
      prometheus.target(
        'mongodb_mongod_connections{service_name="$service", state="current"} or
        mongodb_mongos_connections{service_name="$service", state="current"} or
        mongodb_connections{service_name="$service", state="current"}',
        refId='J',
        interval='$interval',
        step=300,
        intervalFactor=1,
        legendFormat='Connections',
      )
   ),
  gridPos={
      "h": 7,
      "w": 12,
      "x": 0,
      "y": 7
   },
  style=null,
)//38 graph
.addPanel(
  graphPanel.new(
    'Cursors',//title
    description='This shows the number of open cursors for each shard in the cluster. A cursor in MongoDB is a pointer to the result of a given query that can be iterated over. By default a cursor times out after 10 minutes.',
    fill=2,
    linewidth=2,
    datasource='Prometheus',
    height='250px',
    pointradius=5,
    paceLength=10,
    legend_values=true,
    legend_min=true,
    legend_max=true,
    legend_avg=true,
    legend_alignAsTable=true,
    legend_show=true,
    legend_sortDesc=true,
    legend_sort='avg',
    editable=true,
    value_type='cumulative',
    minY1=0,
  )
  .addTarget(
      prometheus.target(
        'mongodb_mongod_metrics_cursor_open{service_name="$service"} or
        mongodb_mongod_cursors{service_name="$service"} or
        mongodb_mongos_metrics_cursor_open{service_name="$service"} or
        mongodb_mongos_cursors{service_name="$service"}',
        refId='J',
        interval='$interval',
        step=300,
        intervalFactor=1,
        legendFormat='{{state}}',
      )
   ),
  gridPos={
      "h": 7,
      "w": 12,
      "x": 12,
      "y": 7
   },
  style=null,
)//25 graph
.addPanel(
  graphPanel.new(
    'Document Operations',//title
    description='This panel shows the actual number of documents that were affected on average during the given time period. A single *update* command for example could perform updates on hundreds or thousands of documents. If these counters seem high, you might want to check your statements to make sure they are properly operating against the documents that they should.',
    fill=2,
    linewidth=2,
    datasource='Prometheus',
    height='250px',
    pointradius=5,
    paceLength=10,
    legend_values=true,
    legend_min=true,
    legend_max=true,
    legend_avg=true,
    legend_alignAsTable=true,
    legend_show=true,
    legend_sortDesc=true,
    legend_sort='avg',
    editable=true,
    value_type='cumulative',
    formatY1='ops',
    minY1=0,
  )
  .addTarget(
      prometheus.target(
        'rate(mongodb_mongod_metrics_document_total{service_name="$service"}[$interval]) or
        irate(mongodb_mongod_metrics_document_total{service_name="$service"}[5m])',
        refId='J',
        interval='$interval',
        step=300,
        intervalFactor=1,
        legendFormat='{{state}}',
      )
   ),
  gridPos={
   "h": 7,
   "w": 12,
   "x": 0,
   "y": 14
   },
  style=null,
)//36 graph
.addPanel(
  graphPanel.new(
    'Queued Operations',//title
    description='This shows the number of read and write operations that are waiting due to for a lock. Consistently small values here should not be of concern, but if the values are consistently high the queries causing long lock times should be tracked down and fixed.',
    fill=2,
    linewidth=2,
    datasource='Prometheus',
    height='250px',
    pointradius=5,
    paceLength=10,
    legend_values=true,
    legend_min=true,
    legend_max=true,
    legend_avg=true,
    legend_alignAsTable=true,
    legend_show=true,
    legend_sortDesc=true,
    legend_sort='avg',
    editable=true,
    value_type='cumulative',
    formatY1='ops',
    minY1=0,
  )
  .addTarget(
      prometheus.target(
        'mongodb_mongod_global_lock_current_queue{service_name="$service"}',
        refId='J',
        interval='$interval',
        step=300,
        intervalFactor=1,
        legendFormat='{{type}}',
      )
   ),
  gridPos={
   "h": 7,
   "w": 12,
   "x": 12,
   "y": 14
   },
  style=null,
)//40 graph
.addPanel(
  graphPanel.new(
    'Query Efficiency',//title
    description='This panel shows how efficient the queries running against this instance are. If the *INDEX* counter is low while queries are running it means you could be missing indexes that would support your queries. If the *DOCUMENT* counter is high it means that there are a lot of documents being returned per query and you might need to check to make sure your queries are returning only the data they need to.',
    fill=2,
    decimals=2,
    linewidth=2,
    nullPointMode="null as zero",
    datasource='Prometheus',
    height='250px',
    pointradius=5,
    paceLength=10,
    legend_values=true,
    legend_min=true,
    legend_max=true,
    legend_avg=true,
    legend_alignAsTable=true,
    legend_show=true,
    legend_sortDesc=true,
    legend_sort='avg',
    editable=true,
    value_type='cumulative',
    formatY1='percentunit',
    formatY2='none',
    minY1=0,
  )
  .addTarget(
      prometheus.target(
        'sum(rate(mongodb_mongod_metrics_document_total{service_name="$service", state="returned"}[$interval]))/
        sum(rate(mongodb_mongod_metrics_query_executor_total{service_name="$service", state="scanned_objects"}[$interval]))
        or
        sum(irate(mongodb_mongod_metrics_document_total{service_name="$service", state="returned"}[5m]))/
        sum(irate(mongodb_mongod_metrics_query_executor_total{service_name="$service", state="scanned_objects"}[5m]))',
        refId='J',
        interval='$interval',
        step=300,
        intervalFactor=1,
        legendFormat='Document',
      )
   )
  .addTarget(
       prometheus.target(
         '(sum(rate(mongodb_mongod_metrics_query_executor_total{service_name="$service", state="scanned"}[$interval]))/
         sum(rate(mongodb_mongod_metrics_query_executor_total{service_name="$service", state="scanned_objects"}[$interval]))
         or
         sum(irate(mongodb_mongod_metrics_query_executor_total{service_name="$service", state="scanned"}[5m]))/
         sum(irate(mongodb_mongod_metrics_query_executor_total{service_name="$service", state="scanned_objects"}[5m])))',
         refId='A',
         interval='$interval',
         step=300,
         intervalFactor=1,
         legendFormat='Index',
       )
    ),
  gridPos={
      "h": 7,
       "w": 12,
       "x": 0,
       "y": 21
   },
  style=null,
)//63 graph
.addPanel(
  graphPanel.new(
    'Scanned and Moved Objects',//title
    description='This panel shows the number of objects (both data (scanned_objects) and index (scanned)) as well as the number of documents that were moved to a new location due to the size of the document growing. Moved documents only apply to the MMAPv1 storage engine.',
    fill=2,
    linewidth=2,
    datasource='Prometheus',
    pointradius=5,
    paceLength=10,
    nullPointMode="null as zero",
    legend_values=true,
    legend_min=true,
    legend_max=true,
    legend_avg=true,
    legend_alignAsTable=true,
    legend_show=true,
    legend_sortDesc=true,
    legend_sort='avg',
    editable=true,
    value_type='cumulative',
    formatY1='ops',
    minY1=0,
  )
  .addTarget(
      prometheus.target(
        'rate(mongodb_mongod_metrics_query_executor_total{service_name="$service"}[$interval]) or
        irate(mongodb_mongod_metrics_query_executor_total{service_name="$service"}[5m])',
        refId='A',
        interval='$interval',
        step=300,
        intervalFactor=1,
        legendFormat='{{state}}',
      )
   )
  .addTarget(
       prometheus.target(
         'rate(mongodb_mongod_metrics_record_moves_total{service_name="$service"}[$interval]) or irate(mongodb_mongod_metrics_record_moves_total{service_name="$service"}[5m])',
         refId='B',
         interval='$interval',
         step=300,
         intervalFactor=1,
         legendFormat='moved',
       )
    ),
  gridPos={
      "h": 7,
       "w": 12,
       "x": 12,
       "y": 21
   },
  style=null,
)//64 graph
.addPanel(
  graphPanel.new(
    'getLastError Write Time',//title
    description='This is useful for write-heavy workloads to understand how long it takes to verify writes and how many concurrent writes are occurring.\n\nYou can read more about [getLastError](https://docs.mongodb.com/manual/reference/command/getLastError/).',
    fill=2,
    linewidth=2,
    datasource='Prometheus',
    height='250px',
    pointradius=5,
    paceLength=10,
    legend_values=true,
    legend_min=true,
    legend_max=true,
    legend_avg=true,
    legend_alignAsTable=true,
    legend_show=true,
    legend_sortDesc=true,
    legend_sort='avg',
    editable=true,
    value_type='cumulative',
    formatY1='ms',
    minY1=0,
  )
  .addTarget(
      prometheus.target(
        'rate(mongodb_mongod_metrics_get_last_error_wtime_total_milliseconds{service_name="$service"}[$interval]) or
        irate(mongodb_mongod_metrics_get_last_error_wtime_total_milliseconds{service_name="$service"}[5m]) or
        rate(mongodb_mongos_metrics_get_last_error_wtime_total_milliseconds{service_name="$service"}[$interval]) or
        irate(mongodb_mongos_metrics_get_last_error_wtime_total_milliseconds{service_name="$service"}[5m])',
        refId='J',
        interval='$interval',
        step=300,
        intervalFactor=1,
        legendFormat='Write Wait Time',
      )
   ),
  gridPos={
        "h": 7,
        "w": 12,
        "x": 0,
        "y": 28
   },
  style=null,
)//41 graph
.addPanel(
  graphPanel.new(
    'getLastError Write Operations',//title
    description='This is useful for write-heavy workloads to understand how long it takes to verify writes and how many concurrent writes are occurring.\n\nYou can read more about [getLastError](https://docs.mongodb.com/manual/reference/command/getLastError/).',
    fill=2,
    linewidth=2,
    datasource='Prometheus',
    height='250px',
    pointradius=5,
    paceLength=10,
    legend_values=true,
    legend_min=true,
    legend_max=true,
    legend_avg=true,
    legend_alignAsTable=true,
    legend_show=true,
    legend_sortDesc=true,
    legend_sort='avg',
    editable=true,
    value_type='cumulative',
    formatY1='ops',
    minY1=0,
  )
  .addTarget(
      prometheus.target(
        'rate(mongodb_mongod_metrics_get_last_error_wtime_num_total{service_name="$service"}[$interval]) or
        irate(mongodb_mongod_metrics_get_last_error_wtime_num_total{service_name="$service"}[5m]) or
        rate(mongodb_mongos_metrics_get_last_error_wtime_num_total{service_name="$service"}[$interval]) or
        irate(mongodb_mongos_metrics_get_last_error_wtime_num_total{service_name="$service"}[5m])',
        refId='J',
        interval='$interval',
        step=300,
        intervalFactor=1,
        legendFormat='Total',
      )
   )
  .addTarget(
       prometheus.target(
         'rate(mongodb_mongod_metrics_get_last_error_wtimeouts_total{service_name="$service"}[$interval]) or
         irate(mongodb_mongod_metrics_get_last_error_wtimeouts_total{service_name="$service"}[5m]) or
         rate(mongodb_mongos_metrics_get_last_error_wtimeouts_total{service_name="$service"}[$interval]) or
         irate(mongodb_mongos_metrics_get_last_error_wtimeouts_total{service_name="$service"}[5m])',
         refId='A',
         interval='$interval',
         step=300,
         intervalFactor=1,
         legendFormat='Timeouts',
       )
    ),
  gridPos={
     "h": 7,
     "w": 12,
     "x": 12,
     "y": 28
   },
  style=null,
)//62 graph
.addPanel(
  graphPanel.new(
    'Assert Events',//title
    description='This panel shows the number of assert events per second on average over the given time period. In most cases assertions are trivial, but you would want to check your log files if this counter spikes or is consistently high.',
    fill=2,
    linewidth=2,
    datasource='Prometheus',
    height='250px',
    pointradius=5,
    paceLength=10,
    legend_values=true,
    legend_min=true,
    legend_max=true,
    legend_avg=true,
    legend_alignAsTable=true,
    legend_show=true,
    legend_sortDesc=true,
    legend_sort='avg',
    editable=true,
    value_type='cumulative',
    minY1=0,
  )
  .addTarget(
      prometheus.target(
        'rate(mongodb_mongod_asserts_total{service_name="$service"}[$interval]) or
        irate(mongodb_mongod_asserts_total{service_name="$service"}[5m]) or
        rate(mongodb_mongos_asserts_total{service_name="$service"}[$interval]) or
        irate(mongodb_mongos_asserts_total{service_name="$service"}[5m]) or
        rate(mongodb_asserts_total{service_name="$service"}[$interval]) or
        irate(mongodb_asserts_total{service_name="$service"}[5m])',
        refId='J',
        interval='$interval',
        step=300,
        intervalFactor=1,
        legendFormat='{{type}}',
      )
   ),
  gridPos={
       "h": 7,
       "w": 12,
       "x": 0,
       "y": 35
   },
  style=null,
)//37 graph
.addPanel(
  graphPanel.new(
    'Page Faults',//title
    description="Page faults indicate that requests are being processed from disk rather than from memory. This is due to there not being enough memory for the current working set. A low number here isn't generally a concern, but if this counter is consistently high, first check to make sure you have indexes on your collections to support the queries you normally run. If the counter stays high, you should consider increasing the server's memory or look into sharding your database.\n\nYou can read more about [Page Faults](https://docs.mongodb.com/manual/administration/analyzing-mongodb-performance/#page-faults).",
    fill=2,
    linewidth=2,
    datasource='Prometheus',
    height='250px',
    pointradius=5,
    paceLength=10,
    legend_values=true,
    legend_min=true,
    legend_max=true,
    legend_avg=true,
    legend_alignAsTable=true,
    legend_show=true,
    legend_sortDesc=true,
    legend_sort='avg',
    editable=true,
    value_type='cumulative',
    minY1=0,
  )
  .addTarget(
      prometheus.target(
        'rate(mongodb_mongod_extra_info_page_faults_total{service_name="$service"}[$interval]) or
        irate(mongodb_mongod_extra_info_page_faults_total{service_name="$service"}[5m]) or
        rate(mongodb_mongos_extra_info_page_faults_total{service_name="$service"}[$interval]) or
        irate(mongodb_mongos_extra_info_page_faults_total{service_name="$service"}[5m]) or
        rate(mongodb_extra_info_page_faults_total{service_name="$service"}[$interval]) or
        irate(mongodb_extra_info_page_faults_total{service_name="$service"}[5m])',
        refId='J',
        interval='$interval',
        step=300,
        intervalFactor=1,
        legendFormat='Faults',
      )
   ),
  gridPos={
       "h": 7,
       "w": 12,
       "x": 12,
       "y": 35
   },
  style=null,
)//39 graph
