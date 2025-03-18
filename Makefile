all:
	emacs -Q --batch -l publish.el -f org-publish-all
clean:
	rm -r public/*
