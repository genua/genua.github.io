#!/bin/sh

pkill jekyll || true

jekyll serve &
