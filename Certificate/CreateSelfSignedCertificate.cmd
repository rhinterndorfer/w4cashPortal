cd "C:\Program Files (x86)\Windows Kits\10\bin\x86"
echo password: !w4cash!
makecert -r -pe -n "CN=www.hb-softsolution.com" C:\Work\GitHub\w4cashPortal\Certificate\w4cash.cer -b 01/01/2016 -e 01/01/2099 -a sha256 -cy end -sky signature -ss my -sv C:\Work\GitHub\w4cashPortal\Certificate\w4cash.pvk
pvk2pfx -pvk C:\Work\GitHub\w4cashPortal\Certificate\w4cash.pvk -pi !w4cash! -spc C:\Work\GitHub\w4cashPortal\Certificate\w4cash.cer -pfx C:\Work\GitHub\w4cashPortal\Certificate\w4cash.pfx -po !w4cash! -f
pause
