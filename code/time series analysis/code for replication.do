use "data for replication.dta"
xtset topic date

*generate logit transformed outcome for VAR analysis
gen t_media_p =log((media_p+.00001)/(1-.00001-media_p))
gen t_localg_p =log((localg_p+.00001)/(1-.00001-localg_p))
gen t_centralg_p =log((centralg_p+.00001)/(1-.00001-centralg_p))
gen t_general_p =log((general_p+.00001)/(1-.00001-general_p))
gen t_attentive_p=log((attentive_p+.00001)/(1-.00001-attentive_p))

*Unit root tests
xtunitroot ht t_media_p 
xtunitroot ht t_centralg_p 
xtunitroot ht t_localg_p 
xtunitroot ht t_general_p 
xtunitroot ht t_attentive_p

*ACF and PACF tests
forvalues i=1/31 {
ac t_media_p if topic==`i',lags(10) gen(t_media_`i')
ac t_general_p if topic==`i',lags(10) gen(t_general_`i')
ac t_attentive_p if topic==`i',lags(10) gen(t_attentive_`i')
ac t_centralg_p if topic==`i',lags(10) gen(t_centralg_`i')
ac t_localg_p if topic==`i',lags(10) gen(t_localg_`i')
}
forvalues i=1/31 {
pac t_media_p if topic==`i',lags(10) gen(t_pmedia_`i')
pac t_general_p if topic==`i',lags(10) gen(t_pgeneral_`i')
pac t_attentive_p if topic==`i',lags(10) gen(t_pattentive_`i')
pac t_centralg_p if topic==`i',lags(10) gen(t_pcentralg_`i')
pac t_localg_p if topic==`i',lags(10) gen(t_plocalg_`i')
}

*code to generate VAR results producing Figure 4
pvar  t_localg_p t_centralg_p t_general_p t_attentive_p t_media_p, exog( stage1 stage2 stage3 stage4 stage5 stage6 ) lags(7)
pvargranger
pvarirf, mc(200) impulse(t_media_p) response(t_centralg_p t_localg_p t_general_p t_attentive_p) cum step(14) save("mediairf_controlstage.dta")
pvarirf, mc(200) impulse(t_centralg_p) response(t_media_p t_localg_p t_general_p t_attentive_p) cum step(14) save("centralgovirf_controlstage.dta")
pvarirf, mc(200) impulse(t_localg_p) response(t_media_p t_centralg_p t_general_p t_attentive_p) cum step(14) save("localgovirf_controlstage.dta")
pvarirf, mc(200) impulse(t_general_p) response(t_centralg_p t_localg_p t_media_p t_attentive_p) cum step(14) save("generalirf_controlstage.dta")
pvarirf, mc(200) impulse(t_attentive_p) response(t_centralg_p t_localg_p t_general_p t_media_p) cum step(14) save("attentiveirf_controlstage.dta")

*code to generate VAR results producing Figure 5
forvalues i=1/31 {
var t_centralg_p t_localg_p t_general_p t_attentive_p t_media_p if topic==`i', lags(1/7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
 irf create t_topic`i', step(14) set(t_topic`i')
 }
 
 use "t_topic1.irf",clear
 keep if step==7
 drop if impulse==response
 keep cirf stdcirf response impulse irfname
 drop if regexm(impulse,"stage")==1
 save "irf by topic.dta",replace
 
 forvalues i=2/31 {
  use "t_topic`i'.irf",clear
 keep if step==7
 drop if impulse==response
 keep cirf stdcirf response impulse irfname
 drop if regexm(impulse,"stage")==1
 append using "irf by topic.dta"
 save "irf by topic.dta",replace
 sleep 2000
 }

*code to generate VAR results producing Figure 6
pvar  t_localg_p t_centralg_p t_general_p t_attentive_p t_media_p if stage1==1 | stage2==1, lags(7)
pvargranger
pvarirf, mc(200) impulse(t_media_p) response(t_centralg_p t_localg_p t_general_p t_attentive_p) cum step(14) save("phase1_mediairf.dta")
pvarirf, mc(200) impulse(t_centralg_p) response(t_media_p t_localg_p t_general_p t_attentive_p) cum step(14) save("phase1_centralgovirf.dta")
pvarirf, mc(200) impulse(t_localg_p) response(t_media_p t_centralg_p t_general_p t_attentive_p) cum step(14) save("phase1_localgovirf.dta")
pvarirf, mc(200) impulse(t_general_p) response(t_centralg_p t_localg_p t_media_p t_attentive_p) cum step(14) save("phase1_generalirf.dta")
pvarirf, mc(200) impulse(t_attentive_p) response(t_centralg_p t_localg_p t_general_p t_media_p) cum step(14) save("phase1_attentiveirf.dta")

pvar  t_localg_p t_centralg_p t_general_p t_attentive_p t_media_p if stage3==1, lags(7)
pvargranger
pvarirf, mc(200) impulse(t_media_p) response(t_centralg_p t_localg_p t_general_p t_attentive_p) cum step(14) save("phase2_mediairf.dta")
pvarirf, mc(200) impulse(t_centralg_p) response(t_media_p t_localg_p t_general_p t_attentive_p) cum step(14) save("phase2_centralgovirf.dta")
pvarirf, mc(200) impulse(t_localg_p) response(t_media_p t_centralg_p t_general_p t_attentive_p) cum step(14) save("phase2_localgovirf.dta")
pvarirf, mc(200) impulse(t_general_p) response(t_centralg_p t_localg_p t_media_p t_attentive_p) cum step(14) save("phase2_generalirf.dta")
pvarirf, mc(200) impulse(t_attentive_p) response(t_centralg_p t_localg_p t_general_p t_media_p) cum step(14) save("phase2_attentiveirf.dta")

pvar  t_localg_p t_centralg_p t_general_p t_attentive_p t_media_p if stage4==1 | stage5==1, lags(7)
pvargranger
pvarirf, mc(200) impulse(t_media_p) response(t_centralg_p t_localg_p t_general_p t_attentive_p) cum step(14) save("phase3_mediairf.dta")
pvarirf, mc(200) impulse(t_centralg_p) response(t_media_p t_localg_p t_general_p t_attentive_p) cum step(14) save("phase3_centralgovirf.dta")
pvarirf, mc(200) impulse(t_localg_p) response(t_media_p t_centralg_p t_general_p t_attentive_p) cum step(14) save("phase3_localgovirf.dta")
pvarirf, mc(200) impulse(t_general_p) response(t_centralg_p t_localg_p t_media_p t_attentive_p) cum step(14) save("phase3_generalirf.dta")
pvarirf, mc(200) impulse(t_attentive_p) response(t_centralg_p t_localg_p t_general_p t_media_p) cum step(14) save("phase3_attentiveirf.dta")

pvar  t_localg_p t_centralg_p t_general_p t_attentive_p t_media_p if stage6==1 | stage7==1, lags(7)
pvargranger
pvarirf, mc(200) impulse(t_media_p) response(t_centralg_p t_localg_p t_general_p t_attentive_p) cum step(14) save("phase4_mediairf.dta")
pvarirf, mc(200) impulse(t_centralg_p) response(t_media_p t_localg_p t_general_p t_attentive_p) cum step(14) save("phase4_centralgovirf.dta")
pvarirf, mc(200) impulse(t_localg_p) response(t_media_p t_centralg_p t_general_p t_attentive_p) cum step(14) save("phase4_localgovirf.dta")
pvarirf, mc(200) impulse(t_general_p) response(t_centralg_p t_localg_p t_media_p t_attentive_p) cum step(14) save("phase4_generalirf.dta")
pvarirf, mc(200) impulse(t_attentive_p) response(t_centralg_p t_localg_p t_general_p t_media_p) cum step(14) save("phase4_attentiveirf.dta")

*code to generate VAR results producing Figure 7
foreach i of varlist media_moral media_sentiment media_cogmech localg_moral localg_sentiment localg_cogmech centralg_moral centralg_sentiment centralg_cogmech general_moral general_sentiment general_cogmech attentive_moral attentive_sentiment attentive_cogmech Trustattentive_public Trustcentral_government Trustgeneral_public Trustmedia Trustregional_government {

replace `i'=0 if `i'==.

}

gen dum_general_sentiment=1 if general_sentiment>=0
replace dum_general_sentiment=0 if general_sentiment<0
gen dum_localg_sentiment=1 if localg_sentiment>=0
replace dum_localg_sentiment=0 if localg_sentiment<0


gen dum_localg_moral =1 if localg_moral >=0
replace dum_localg_moral =0 if localg_moral <0
gen dum_general_moral =1 if general_moral >=0
replace dum_general_moral =0 if general_moral <0
gen dum_centralg_moral =1 if centralg_moral >=0 & centralg_moral!=.
replace dum_centralg_moral =0 if centralg_moral <0 & centralg_moral!=.

gen dum_general_cogmech=1 if general_cogmech>=.0800577
replace dum_general_cogmech=0 if general_cogmech<.0800577
gen dum_localg_cogmech =1 if localg_cogmech>=.0717295
replace dum_localg_cogmech =0 if localg_cogmech<.0717295
gen dum_centralg_cogmech =1 if centralg_cogmech>=.076264 & centralg_cogmech!=.
replace dum_centralg_cogmech =0 if centralg_cogmech<.076264 & centralg_cogmech!=.

gen dum_localg_trust =1 if Trustregional_government>0
replace dum_localg_trust =0 if Trustregional_government==0
gen dum_general_trust =1 if Trustgeneral_public>0
replace dum_general_trust =0 if Trustgeneral_public==0

gen t_psgeneral_p=dum_general_sentiment*t_general_p
gen t_nsgeneral_p=(1-dum_general_sentiment)*t_general_p
gen t_pslocalg_p=dum_localg_sentiment*t_localg_p
gen t_nslocalg_p=(1-dum_localg_sentiment)*t_localg_p

gen t_pmlocalg_p=dum_localg_moral*t_localg_p
gen t_nmlocalg_p=(1-dum_localg_moral)*t_localg_p
gen t_pmgeneral_p=dum_general_moral*t_general_p
gen t_nmgeneral_p=(1-dum_general_moral)*t_general_p

gen t_pcgeneral_p=dum_general_cogmech*t_general_p
gen t_ncgeneral_p=(1-dum_general_cogmech)*t_general_p
gen t_pclocalg_p=dum_localg_cogmech*t_localg_p
gen t_nclocalg_p=(1-dum_localg_cogmech)*t_localg_p  

gen t_ptgeneral_p=dum_general_trust*t_general_p
gen t_ntgeneral_p=(1-dum_general_trust)*t_general_p
gen t_ptlocalg_p=dum_localg_trust*t_localg_p
gen t_ntlocalg_p=(1-dum_localg_trust)*t_localg_p 

gen t_pccentralg_p=dum_centralg_cogmech*t_centralg_p
gen t_nccentralg_p=(1-dum_centralg_cogmech)*t_centralg_p  
gen t_pmcentralg_p=dum_centralg_moral*t_centralg_p
gen t_nmcentralg_p=(1-dum_centralg_moral)*t_centralg_p 
 
pvar t_centralg_p t_localg_p t_psgeneral_p t_nsgeneral_p t_attentive_p t_media_p , lags(7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
pvarirf, mc(200) impulse(t_psgeneral_p t_nsgeneral) response(t_localg_p t_centralg_p) cum step(7) save("t_sgeneral_irf.dta")

pvar t_centralg_p t_localg_p t_general_p t_pslocalg_p t_nslocalg_p t_attentive_p t_media_p , lags(7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
pvarirf, mc(200) impulse(t_pslocalg_p t_nslocalg_p) response(t_general_p t_centralg_p) cum step(7) save("t_sgov_irf.dta")

pvar t_centralg_p t_localg_p t_pcgeneral_p t_ncgeneral_p t_attentive_p t_media_p , lags(7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
pvarirf, mc(200) impulse(t_pcgeneral_p t_ncgeneral_p) response(t_localg_p t_centralg_p) cum step(7) save("t_cgeneral_irf.dta")

pvar t_centralg_p t_pclocalg_p t_nclocalg_p t_general_p t_attentive_p media_p , lags(7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
pvarirf, mc(200) impulse(t_pclocalg_p t_nclocalg_p) response(t_general_p t_centralg_p t_attentive_p) cum step(7) save("t_cgov_irf.dta") 

pvar t_centralg_p t_pmlocalg_p t_nmlocalg_p t_general_p t_attentive_p t_media_p , lags(7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
pvarirf, mc(200) impulse(t_pmlocalg_p t_nmlocalg_p) response(t_general_p t_centralg_p t_attentive_p) cum step(7) save("t_mgov_irf.dta")

pvar t_centralg_p t_localg_p t_pmgeneral_p t_nmgeneral_p t_attentive_p t_media_p , lags(7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
pvarirf, mc(200) impulse(t_pmgeneral_p t_nmgeneral_p) response(t_localg_p t_centralg_p) cum step(7) save("t_mgeneral_irf.dta")

pvar t_centralg_p t_ptlocalg_p t_ntlocalg_p t_general_p t_attentive_p media_p , lags(7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
pvarirf, mc(200) impulse(t_ptlocalg_p t_ntlocalg_p) response(t_general_p t_centralg_p t_attentive_p) cum step(7) save("t_tgov_irf.dta") 

pvar t_centralg_p t_localg_p t_ptgeneral_p t_ntgeneral_p t_attentive_p t_media_p , lags(7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
pvarirf, mc(200) impulse(t_ptgeneral_p t_ntgeneral_p) response(t_localg_p t_centralg_p) cum step(7) save("t_tgeneral_irf.dta")

pvar t_pccentralg_p t_nccentralg_p t_localg_p t_general_p t_attentive_p t_media_p , lags(7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
pvarirf, mc(200) impulse(t_pccentralg_p t_nccentralg_p) response(t_localg_p t_general_p t_attentive_p) cum step(7) save("t_ccentralg_irf.dta")

pvar t_pmcentralg_p t_nmcentralg_p t_localg_p t_general_p t_attentive_p t_media_p , lags(7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
pvarirf, mc(200) impulse(t_pmcentralg_p t_nmcentralg_p) response(t_localg_p t_general_p t_attentive_p) cum step(7) save("t_mcentralg_irf.dta")

*code to generate VAR results producing Figure 8
forvalues i=1/31 {
var t_centralg_p new_vaccinations_per_mi  if topic==`i', lags(8/14) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
 irf create cgtopic`i', step(14) set(cgtopic`i') 
var t_localg_p new_vaccinations_per_mi if topic==`i', lags(8/14) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
 irf create lgtopic`i', step(14) set(lgtopic`i') 
var t_general_p new_vaccinations_per_mi if topic==`i', lags(8/14) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
 irf create gentopic`i', step(14) set(gentopic`i') 
var t_attentive_p new_vaccinations_per_mi if topic==`i', lags(8/14) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
 irf create attopic`i', step(14) set(attopic`i') 
var t_media_p new_vaccinations_per_mi if topic==`i', lags(8/14) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
 irf create mediatopic`i', step(14) set(mediatopic`i') 
 }
 
 
 use "cgtopic1.irf",clear
 append using "lgtopic1.irf"
 append using "gentopic1.irf"
 append using "attopic1.irf"
 append using "mediatopic1.irf"
 keep if step==14
 keep cirf stdcirf response impulse irfname
 save "irf by topic.dta",replace
 
 forvalues i=2/31 {
 use "cgtopic`i'.irf",clear
 append using "lgtopic`i'.irf"
 append using "gentopic`i'.irf"
 append using "attopic`i'.irf"
 append using "mediatopic`i'.irf"
 keep if step==14
 keep cirf stdcirf response impulse irfname
 append using "irf by topic.dta"
 save "irf by topic.dta",replace
 sleep 1000
 }
 drop if impulse== response
 drop if regexm(impulse,"stage")==1
 
*robustness check of the main analysis using shorter or longer lags
pvar  t_localg_p t_centralg_p t_general_p t_attentive_p t_media_p, exog( stage1 stage2 stage3 stage4 stage5 stage6 ) lags(5)
pvargranger
pvarirf, mc(200) impulse(t_media_p) response(t_centralg_p t_localg_p t_general_p t_attentive_p) cum step(14) save("mediairf_lag5.dta")
pvarirf, mc(200) impulse(t_centralg_p) response(t_media_p t_localg_p t_general_p t_attentive_p) cum step(14) save("centralgovirf_lag5.dta")
pvarirf, mc(200) impulse(t_localg_p) response(t_media_p t_centralg_p t_general_p t_attentive_p) cum step(14) save("localgovirf_lag5.dta")
pvarirf, mc(200) impulse(t_general_p) response(t_centralg_p t_localg_p t_media_p t_attentive_p) cum step(14) save("generalirf_lag5.dta")
pvarirf, mc(200) impulse(t_attentive_p) response(t_centralg_p t_localg_p t_general_p t_media_p) cum step(14) save("attentiveirf_lag5.dta")

pvar  t_localg_p t_centralg_p t_general_p t_attentive_p t_media_p, exog( stage1 stage2 stage3 stage4 stage5 stage6 ) lags(10)
pvargranger
pvarirf, mc(200) impulse(t_media_p) response(t_centralg_p t_localg_p t_general_p t_attentive_p) cum step(14) save("mediairf_lag10.dta")
pvarirf, mc(200) impulse(t_centralg_p) response(t_media_p t_localg_p t_general_p t_attentive_p) cum step(14) save("centralgovirf_lag10.dta")
pvarirf, mc(200) impulse(t_localg_p) response(t_media_p t_centralg_p t_general_p t_attentive_p) cum step(14) save("localgovirf_lag10.dta")
pvarirf, mc(200) impulse(t_general_p) response(t_centralg_p t_localg_p t_media_p t_attentive_p) cum step(14) save("generalirf_lag10.dta")
pvarirf, mc(200) impulse(t_attentive_p) response(t_centralg_p t_localg_p t_general_p t_media_p) cum step(14) save("attentiveirf_lag10.dta")


*code to generate VAR results producing Supplementary Figure 11-14

foreach i of varlist media_moral media_sentiment media_cogmech localg_moral localg_sentiment localg_cogmech centralg_moral centralg_sentiment centralg_cogmech general_moral general_sentiment general_cogmech attentive_moral attentive_sentiment attentive_cogmech Trustattentive_public Trustcentral_government Trustgeneral_public Trustmedia Trustregional_government {

replace `i'=0 if `i'==.

}
duplicates drop date,force
tsset date

var media_moral localg_moral centralg_moral general_moral attentive_moral, lags(1/7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
vargranger
irf create moral1, step(14) set(moral1) 
var  media_sentiment localg_sentiment centralg_sentiment general_sentiment attentive_sentiment, lags(1/7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
vargranger
irf create sentiment1, step(14) set(sentiment1)
var media_cogmech localg_cogmech centralg_cogmech general_cogmech attentive_cogmech, lags(1/7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
vargranger
irf create cogmech1, step(14) set(cogmech1)
var Trustattentive_public Trustcentral_government Trustgeneral_public Trustmedia Trustregional_government, lags(1/7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
vargranger
irf create trust1, step(14) set(trust1)
var  media_sentiment localg_sentiment centralg_sentiment general_sentiment attentive_sentiment general_moral attentive_moral, lags(1/7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
vargranger
irf create sentiment_trust, step(14) set(sentiment_trust)

*code to generate VAR results producing supplementary Figure 15
forvalues i=1/31 {
var t_centralg_p log_ncase  if topic==`i', lags(1/7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
 irf create cgtopic`i', step(14) set(cgtopic`i') 
var t_localg_p log_ncase if topic==`i', lags(1/7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
 irf create lgtopic`i', step(14) set(lgtopic`i') 
var t_general_p log_ncase if topic==`i', lags(1/7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
 irf create gentopic`i', step(14) set(gentopic`i') 
var t_attentive_p log_ncase if topic==`i', lags(1/7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
 irf create attopic`i', step(14) set(attopic`i') 
var t_media_p log_ncase if topic==`i', lags(1/7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
 irf create mediatopic`i', step(14) set(mediatopic`i') 
 }
	
use "cgtopic1.irf",clear
 append using "lgtopic1.irf"
 append using "gentopic1.irf"
 append using "attopic1.irf"
 append using "mediatopic1.irf"
 keep if step==7
 keep cirf stdcirf response impulse irfname
  drop if regexm(impulse,"stage")==1
 save "irf by topic.dta",replace
 
 forvalues i=2/31 {
 use "cgtopic`i'.irf",clear
 append using "lgtopic`i'.irf"
 append using "gentopic`i'.irf"
 append using "attopic`i'.irf"
 append using "mediatopic`i'.irf"
 keep if step==7
 keep cirf stdcirf response impulse irfname
  drop if regexm(impulse,"stage")==1
 append using "irf by topic.dta"
 save "irf by topic.dta",replace
 sleep 1000
 }
 drop if impulse== response
 
*code to generate VAR results producing supplementary Figure 16
forvalues i=1/31 {
var t_centralg_p new_vaccinations_per_mi  if topic==`i', lags(1/7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
 irf create cgtopic`i', step(14) set(cgtopic`i') 
var t_localg_p new_vaccinations_per_mi if topic==`i', lags(1/7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
 irf create lgtopic`i', step(14) set(lgtopic`i') 
var t_general_p new_vaccinations_per_mi if topic==`i', lags(1/7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
 irf create gentopic`i', step(14) set(gentopic`i') 
var t_attentive_p new_vaccinations_per_mi if topic==`i', lags(1/7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
 irf create attopic`i', step(14) set(attopic`i') 
var t_media_p new_vaccinations_per_mi if topic==`i', lags(1/7) exog( stage1 stage2 stage3 stage4 stage5 stage6 )
 irf create mediatopic`i', step(14) set(mediatopic`i') 
 }
	
use "cgtopic1.irf",clear
 append using "lgtopic1.irf"
 append using "gentopic1.irf"
 append using "attopic1.irf"
 append using "mediatopic1.irf"
 keep if step==7
 keep cirf stdcirf response impulse irfname
  drop if regexm(impulse,"stage")==1
 save "irf by topic.dta",replace
 
 forvalues i=2/31 {
 use "cgtopic`i'.irf",clear
 append using "lgtopic`i'.irf"
 append using "gentopic`i'.irf"
 append using "attopic`i'.irf"
 append using "mediatopic`i'.irf"
 keep if step==7
 keep cirf stdcirf response impulse irfname
  drop if regexm(impulse,"stage")==1
 append using "irf by topic.dta"
 save "irf by topic.dta",replace
 sleep 1000
 }
 drop if impulse== response