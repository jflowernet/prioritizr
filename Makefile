all: clean contrib initc data docs test check

clean:
	rm -rf man/*

initc:
	R --slave -e "Rcpp::compileAttributes()"
	R --slave -e "tools::package_native_routine_registration_skeleton('.', 'src/init.c', character_only = FALSE)"

docs: man readme vigns site

data:
	Rscript --slave inst/extdata/simulate_data.R

man:
	R --slave -e "devtools::document()"

readme:
	R --slave -e "rmarkdown::render('README.Rmd')"
	cp docs/logo.png man/figures

contrib:
	R --slave -e "rmarkdown::render('CONTRIBUTING.Rmd')"

vigns:
	rm -f vignettes/*.html
	rm -f .build.timestamp
	rm -f vignettes/*.R
	rm -f doc/*.html
	rm -f doc/*.Rmd
	rm -f inst/doc/*.html
	rm -f inst/doc/*.Rmd
	R --slave -e "devtools::build_vignettes()"
	cp -R doc inst/
	touch inst/doc/.gitkeep

quicksite:
	cp docs/favicon.ico /tmp
	cp docs/logo.png /tmp
	R --slave -e "pkgdown::build_site(run_dont_run = TRUE, lazy = TRUE)"
	rm docs/CNAME
	echo "prioritizr.net\c" >> docs/CNAME
	cp -R doc inst/
	cp /tmp/favicon.ico docs
	cp /tmp/logo.png docs
	cp /tmp/logo.png docs/reference/figures

site:
	cp docs/favicon.ico /tmp
	cp docs/logo.png /tmp
	R --slave -e "pkgdown::clean_site()"
	R --slave -e "pkgdown::build_site(run_dont_run = TRUE, lazy = FALSE)"
	rm -f docs/CNAME
	echo "prioritizr.net\c" >> docs/CNAME
	cp -R doc inst/
	cp /tmp/favicon.ico docs
	cp /tmp/logo.png docs
	cp /tmp/logo.png docs/reference/figures

test:
	R --slave -e "devtools::test()" > test.log 2>&1
	rm -f tests/testthat/Rplots.pdf

quickcheck:
	echo "\n===== R CMD CHECK =====\n" > check.log 2>&1
	R --slave -e "devtools::check(build_args = '--no-build-vignettes', args = '--no-build-vignettes', run_dont_test = TRUE, vignettes = FALSE)" >> check.log 2>&1
	cp -R doc inst/
	touch inst/doc/.gitkeep

check:
	echo "\n===== R CMD CHECK =====\n" > check.log 2>&1
	R --slave -e "devtools::check(build_args = '--no-build-vignettes', args = '--no-build-vignettes', run_dont_test = TRUE, vignettes = FALSE)" >> check.log 2>&1
	cp -R doc inst/
	touch inst/doc/.gitkeep

purl_vigns:
	R --slave -e "lapply(dir('vignettes', '^.*\\\\.Rmd$$'), function(x) knitr::purl(file.path('vignettes', x), gsub('.Rmd', '.R', x, fixed = TRUE)))"

wbcheck:
	R --slave -e "devtools::check_win_devel()"
	cp -R doc inst/

solarischeck:
	R --slave -e "rhub::check(platform = 'solaris-x86-patched', email = 'jeffrey.hanson@uqconnect.edu.au', show_status = FALSE)"

asancheck:
	R --slave -e "rhub::check(platform = 'linux-x86_64-rocker-gcc-san', email = 'jeffrey.hanson@uqconnect.edu.au', show_status = FALSE)"

spellcheck:
	R --slave -e "devtools::document();devtools::spell_check()"

build:
	R --slave -e "devtools::build()"
	cp -R doc inst/
	touch inst/doc/.gitkeep

install:
	R --slave -e "devtools::install_local('../prioritizr')"

examples:
	R --slave -e "devtools::run_examples(test = TRUE, run = TRUE);warnings()"  >> examples.log
	rm -f Rplots.pdf

.PHONY: initc clean data docs readme contrib site test check checkwb build install man spellcheck examples
