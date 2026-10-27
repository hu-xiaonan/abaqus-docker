#!/bin/bash
systemctl start flexlmsrvssq
exec "$@"
