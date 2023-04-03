{
  prometheusRules+:: {
    groups+: [
      {
        name: 'mongo-exporter.rules',
        rules: [
          {
            // This rule gives uptime of each mongodb node.
            record: 'instance:uptime:avg',
            expr: |||
              avg by (%(aggLabel)s) (
                mongodb_instance_uptime_seconds{%(servicenameSelector)s}
              )
            ||| % $._config,
          },
          {
            // Query per second % type without {command}.
            record: 'instance:mongodb_op_counters_total:rate%(rateInterval)s' % $._config,
            expr: |||
                sum(rate(mongodb_mongod_op_counters_total{%(servicenameSelector)s,type!="command"}[%(rateInterval)s])
              or
                irate(mongodb_mongod_op_counters_total{%(servicenameSelector)s,type!="command"}[5m])
              or
                rate(mongodb_op_counters_total{%(servicenameSelector)s,type!="command"}[%(rateInterval)s])
              or
                irate(mongodb_op_counters_total{%(servicenameSelector)s,type!="command"}[5m]))
            ||| % $._config,
          },
          {
            // Latency for MongoDB.
            record: 'instance:mongod_op_latencies_latency_total:rate%(rateInterval)s',
            expr: |||
                avg by (service_name) (rate(mongodb_mongod_op_latencies_latency_total{%(servicenameSelector)s,type="command"}[%(rateInterval)s]])
              /
                (rate(mongodb_mongod_op_latencies_ops_total{%(servicenameSelector)s,type="command"}[%(rateInterval)s]]) > 0)
              or
                irate(mongodb_mongod_op_latencies_latency_total{%(servicenameSelector)s,type="command"}[5m])
              /
                (irate(mongodb_mongod_op_latencies_ops_total{%(servicenameSelector)s,type="command"}[5m]) > 0))
            ||| % $._config,
          },
          {
            // Memory utilisation (ratio of used memory per instance).
            record: 'instance:node_memory_utilisation:ratio',
            expr: |||
              1 - (
                (
                  node_memory_MemAvailable_bytes{%(nodeExporterSelector)s}
                  or
                  (
                    node_memory_Buffers_bytes{%(nodeExporterSelector)s}
                    +
                    node_memory_Cached_bytes{%(nodeExporterSelector)s}
                    +
                    node_memory_MemFree_bytes{%(nodeExporterSelector)s}
                    +
                    node_memory_Slab_bytes{%(nodeExporterSelector)s}
                  )
                )
              /
                node_memory_MemTotal_bytes{%(nodeExporterSelector)s}
              )
            ||| % $._config,
          },
          {
            record: 'instance:node_vmstat_pgmajfault:rate%(rateInterval)s' % $._config,
            expr: |||
              rate(node_vmstat_pgmajfault{%(nodeExporterSelector)s}[%(rateInterval)s])
            ||| % $._config,
          },
          {
            // Disk utilisation (seconds spent, 1 second rate).
            record: 'instance_device:node_disk_io_time_seconds:rate%(rateInterval)s' % $._config,
            expr: |||
              rate(node_disk_io_time_seconds_total{%(nodeExporterSelector)s, %(diskDeviceSelector)s}[%(rateInterval)s])
            ||| % $._config,
          },
          {
            // Disk saturation (weighted seconds spent, 1 second rate).
            record: 'instance_device:node_disk_io_time_weighted_seconds:rate%(rateInterval)s' % $._config,
            expr: |||
              rate(node_disk_io_time_weighted_seconds_total{%(nodeExporterSelector)s, %(diskDeviceSelector)s}[%(rateInterval)s])
            ||| % $._config,
          },
          {
            record: 'instance:node_network_receive_bytes_excluding_lo:rate%(rateInterval)s' % $._config,
            expr: |||
              sum without (device) (
                rate(node_network_receive_bytes_total{%(nodeExporterSelector)s, device!="lo"}[%(rateInterval)s])
              )
            ||| % $._config,
          },
          {
            record: 'instance:node_network_transmit_bytes_excluding_lo:rate%(rateInterval)s' % $._config,
            expr: |||
              sum without (device) (
                rate(node_network_transmit_bytes_total{%(nodeExporterSelector)s, device!="lo"}[%(rateInterval)s])
              )
            ||| % $._config,
          },
          // TODO: Find out if those drops ever happen on modern switched networks.
          {
            record: 'instance:node_network_receive_drop_excluding_lo:rate%(rateInterval)s' % $._config,
            expr: |||
              sum without (device) (
                rate(node_network_receive_drop_total{%(nodeExporterSelector)s, device!="lo"}[%(rateInterval)s])
              )
            ||| % $._config,
          },
          {
            record: 'instance:node_network_transmit_drop_excluding_lo:rate%(rateInterval)s' % $._config,
            expr: |||
              sum without (device) (
                rate(node_network_transmit_drop_total{%(nodeExporterSelector)s, device!="lo"}[%(rateInterval)s])
              )
            ||| % $._config,
          },
        ],
      },
    ],
  },
}
