
if ($?PYTHONPATH) then
  setenv PYTHONPATH "./laygo2:$PYTHONPATH"
else
  setenv PYTHONPATH "./laygo2"
endif
