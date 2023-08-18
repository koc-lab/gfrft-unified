all: style metric lint

style:
	@mh_style --process-slx --fix --input-encoding "utf8" .

metric:
	@mh_metric --ci .

lint:
	@mh_lint .
