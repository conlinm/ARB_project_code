# define concept sets using the concept ids
#ARBs
arb_cs <- cs(
  descendants(
    1308842, # valsartan
    1317640, # telmisartan
    1346686, # eprosartan
    1347384, # irbesartan
    1351557, # candesartan
    1367500, # losartan
    40226742, # olmesartan
    40235485
  ), # azilsartan
  name = "ARBs"
)

#non-ARB antihypertensives
non_arb_cs <- cs(
  descendants(
    21601783, # ACE inhibitors
    21601801, # ACE combinations
    21601744, # calcium channel blockers
    21601461, # diuretics
    21601665
  ), # beta blockers
  name = "non_ARBs"
)

# renal cell carcinoma
rcc_cs <- cs(
  descendants(
    37116954, # clear cell RCC
    45765451, # renal cell carcinoma
    45773365
  ), # metastatic RCC
  198985, # primary malignant neoplasm of kidney
  name = "RCC"
)

# hypertension
htn_cs <- cs(
  descendants(316866), # hypertensive disorder
  name = "hypertension"
)

# transplant status
transplant_cs <- cs(
  descendants(42537741), # transplant present
  name = "tx_status"
)

#ESRD
esrd_cs <- cs(
  descendants(
    193782, # end-stage renal disease
    443611, # chronic kidney disease stage 5
    37395652
  ), # anemia in chronic kidney disease
  name = "ESRD"
)

# genetic hereditary RCCa
hereditary_rcc_cs <- cs(
  descendants(
    380839, #tuberous sclerosis
    4110719, # fibrofolliculoma
    4263213
  ), # von Hippel-Lindau disease
  35622838, #BAP1 tumor predisposition syndrome
  37160584, # hereditary leiomyomatosis and renal cell carcinoma syndrome
  37396489, # Lynch syndrome
  37399456, # hereditary papillary renal cell carcinoma
  4240212, # cowden syndrome
  name = "hereditary_RCC"
)
