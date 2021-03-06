#
# Copyright (c) 2018-2019 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
FROM mikefarah/yq as builder
RUN apk add --no-cache bash
COPY .htaccess README.md *.sh /build/
COPY /plugins /build/plugins
COPY /v2 /build/v2
COPY /v3 /build/v3
WORKDIR /build/
RUN ./check_plugins_location_v1.sh
RUN ./check_plugins_location_v2.sh v2
RUN ./check_plugins_location_v2.sh v3
RUN ./check_plugins_images.sh
RUN ./set_plugin_dates.sh
RUN ./check_plugins_viewer_mandatory_fields_v1.sh
RUN ./check_plugins_viewer_mandatory_fields_v2.sh
RUN ./check_plugins_viewer_mandatory_fields_v3.sh
RUN ./index.sh > /build/plugins/index.json
RUN ./index_v2.sh v2 > /build/v2/plugins/index.json
RUN ./index_v2.sh v3 > /build/v3/plugins/index.json

FROM registry.centos.org/centos/httpd-24-centos7
RUN mkdir /var/www/html/plugins
COPY --from=builder /build/ /var/www/html/
USER 0
RUN chmod -R g+rwX /var/www/html/plugins && \
    chmod -R g+rwX /var/www/html/v2/plugins && \
    chmod -R g+rwX /var/www/html/v3/plugins
