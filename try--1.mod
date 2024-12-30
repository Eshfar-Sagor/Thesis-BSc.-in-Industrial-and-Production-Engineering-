/*********************************************
 * OPL 12.6.1.0 Model
 * Author: ESHFAR
 * Creation Date: Nov 16, 2022 at 8:51:45 PM
 *********************************************/

//sets
{string} OPs=...;//i
{string} ODCs=...;//j
{string} candidate_ODC=...;//a
{string} DPs=...;//r
{string} oxygen=...;//g
{string} vehicles=...;//l
{string} scenarios=...;//s


//parameters

float w1=...;
float w2=...;
int total_budget=...;//B
int total_available_quantity_oxygen_OPs[oxygen][OPs]=...;//k(i_g)
float capacity_of_candidate_ODC[scenarios][oxygen][candidate_ODC]=...;//Na
int Max_num_candidate_ODC=...;//H
float cost_establishing_candidate_ODC[candidate_ODC]=...;//Ca
float per_unit_cost_vehicle[vehicles]=...;//Cl

float weight_commodity[oxygen]=...;//Wg
float volume_commodity[oxygen]=...;//Vg

float weight_vehicle[vehicles]=...;//Wl
float volume_vehicle[vehicles]=...;//Vl

float distance_OPs_ODCs[OPs][ODCs]=...;//Sij
float distance_OPs_candidate_ODC[OPs][candidate_ODC]=...;//Eia
float distance_ODCs_DPs[ODCs][DPs]=...;//Mjr
float distance_candidate_ODC_DPs[candidate_ODC][DPs]=...;//Far


int demand_oxygen_DPs[scenarios][oxygen][DPs]=...;//D(g_r)

float capacity_of_ODC[oxygen][ODCs]=...;//Pj

float shortage_cost_unsatisfied_demand_oxygen_DPs[oxygen][DPs]=...;//Trg

float emergency_rating=...;//alpha

int total_number_vehicle[vehicles]=...;//NVt

float probablity_scen[scenarios]=...;
//TIME
float Max_speed=...;
//float max_time=...;

float load_unload_time[scenarios]=...;

//Decision variables
dvar int+ quantity_oxygen_OPs_ODCs[scenarios][OPs][ODCs][oxygen];//x
dvar int+ quantity_oxygen_OPs_candidate_ODC[scenarios][OPs][candidate_ODC][oxygen];//w
dvar int+ quantity_oxygen_ODCs_DPs[scenarios][ODCs][DPs][oxygen];//z
dvar int+ quantity_oxygen_candidate_ODC_DPs[scenarios][candidate_ODC][DPs][oxygen];//v

dvar int+ number_vehicle_OPs_ODCs[scenarios][OPs][ODCs][vehicles];//NVij
dvar int+ number_vehicle_OPs_candidate_ODC[scenarios][OPs][candidate_ODC][vehicles];//NVia
dvar int+ number_vehicle_ODCs_DPs[scenarios][ODCs][DPs][vehicles];//jr
dvar int+ number_vehicle_candidate_ODC_DPs[scenarios][candidate_ODC][DPs][vehicles];//ar

dvar float optimal_cost[scenarios];
dvar float optimal_time[scenarios];

dvar boolean establishes_candidate_ODCs[candidate_ODC];//ya,1, if potential ODC is established at candidate location

dvar int+ shortage_demand_oxygen_DPs[scenarios][oxygen][DPs];//SHrg

//TIME
dvar float+ time_OPs_ODCs[scenarios][OPs][ODCs];
dvar float+ time_OPs_candidate_ODC[scenarios][OPs][candidate_ODC];
dvar float+ time_ODCs_DPs[scenarios][ODCs][DPs];
dvar float+ time_candidate_ODC_DPs[scenarios][candidate_ODC][DPs];


//objective function
minimize w1*sum(s in scenarios)probablity_scen[s]*(sum(a in candidate_ODC)cost_establishing_candidate_ODC[a]*establishes_candidate_ODCs[a]+
sum(l in vehicles)per_unit_cost_vehicle[l]*(
sum(i in OPs,j in ODCs,s in scenarios)distance_OPs_ODCs[i][j]*number_vehicle_OPs_ODCs[s][i][j][l]+
sum(i in OPs,a in candidate_ODC,s in scenarios)distance_OPs_candidate_ODC[i][a]*number_vehicle_OPs_candidate_ODC[s][i][a][l]+
sum(j in ODCs,r in DPs,s in scenarios)distance_ODCs_DPs[j][r]*number_vehicle_ODCs_DPs[s][j][r][l]+
sum(a in candidate_ODC,r in DPs,s in scenarios)distance_candidate_ODC_DPs[a][r]*number_vehicle_candidate_ODC_DPs[s][a][r][l])+
sum(r in DPs,g in oxygen,s in scenarios)shortage_cost_unsatisfied_demand_oxygen_DPs[g][r]*shortage_demand_oxygen_DPs[s][g][r])+
w2*sum(s in scenarios)probablity_scen[s]*(sum(i in OPs,j in ODCs,s in scenarios)time_OPs_ODCs[s][i][j]+
sum(i in OPs,a in candidate_ODC,s in scenarios)time_OPs_candidate_ODC[s][i][a]+
sum(j in ODCs,r in DPs,s in scenarios)time_ODCs_DPs[s][j][r]+
sum(a in candidate_ODC,r in DPs,s in scenarios)time_candidate_ODC_DPs[s][a][r]+
sum(s in scenarios)load_unload_time[s]*
(sum(i in OPs,j in ODCs,g in oxygen,s in scenarios)quantity_oxygen_OPs_ODCs[s][i][j][g]+
sum(i in OPs,a in candidate_ODC,g in oxygen,s in scenarios)quantity_oxygen_OPs_candidate_ODC[s][i][a][g]+
sum(j in ODCs,r in DPs,g in oxygen,s in scenarios)quantity_oxygen_ODCs_DPs[s][j][r][g]+
sum(a in candidate_ODC,r in DPs,g in oxygen,s in scenarios)quantity_oxygen_candidate_ODC_DPs[s][a][r][g]));

//constrains

subject to
{

//1
forall(g in oxygen,r in DPs,s in scenarios)
  (sum(j in ODCs)quantity_oxygen_ODCs_DPs[s][j][r][g]+sum(a in candidate_ODC)quantity_oxygen_candidate_ODC_DPs[s][a][r][g])>=demand_oxygen_DPs[s][g][r];

  
//2
forall(g in oxygen,r in DPs,s in scenarios)
  sum(j in ODCs)quantity_oxygen_ODCs_DPs[s][j][r][g]+sum(a in candidate_ODC)quantity_oxygen_candidate_ODC_DPs[s][a][r][g]+shortage_demand_oxygen_DPs[s][g][r]==emergency_rating*demand_oxygen_DPs[s][g][r];

  
//3
forall(g in oxygen,i in OPs,s in scenarios)
  sum(j in ODCs)quantity_oxygen_OPs_ODCs[s][i][j][g]+sum(a in candidate_ODC)quantity_oxygen_OPs_candidate_ODC[s][i][a][g]<=total_available_quantity_oxygen_OPs[g][i];

//4
forall(g in oxygen,j in ODCs,s in scenarios)
  sum(i in OPs)quantity_oxygen_OPs_ODCs[s][i][j][g]<=capacity_of_ODC[g][j];


//5
forall(g in oxygen,a in candidate_ODC,s in scenarios)
  sum(i in OPs)quantity_oxygen_OPs_candidate_ODC[s][i][a][g]<=capacity_of_candidate_ODC[s][g][a]*establishes_candidate_ODCs[a];

//6
forall(g in oxygen,j in ODCs,s in scenarios)
  sum(i in OPs)quantity_oxygen_OPs_ODCs[s][i][j][g]>=sum(r in DPs)quantity_oxygen_ODCs_DPs[s][j][r][g];


//7
forall(g in oxygen,a in candidate_ODC,s in scenarios)
  sum(i in OPs)quantity_oxygen_OPs_candidate_ODC[s][i][a][g]>=sum(r in DPs)quantity_oxygen_candidate_ODC_DPs[s][a][r][g];


//8
sum(a in candidate_ODC)establishes_candidate_ODCs[a]<= Max_num_candidate_ODC;


//9
forall(j in ODCs,i in OPs,s in scenarios)
  sum(g in oxygen)quantity_oxygen_OPs_ODCs[s][i][j][g]*weight_commodity[g]<=sum(l in vehicles)number_vehicle_OPs_ODCs[s][i][j][l]*weight_vehicle[l];


//10
forall(j in ODCs,i in OPs,s in scenarios)
  sum(g in oxygen)quantity_oxygen_OPs_ODCs[s][i][j][g]*volume_commodity[g]<=sum(l in vehicles)number_vehicle_OPs_ODCs[s][i][j][l]*volume_vehicle[l];
  

//11
forall(a in candidate_ODC,i in OPs,s in scenarios)
  sum(g in oxygen)quantity_oxygen_OPs_candidate_ODC[s][i][a][g]*weight_commodity[g]<=sum(l in vehicles)number_vehicle_OPs_candidate_ODC[s][i][a][l]*weight_vehicle[l];


//12
forall(a in candidate_ODC,i in OPs,s in scenarios)
  sum(g in oxygen)quantity_oxygen_OPs_candidate_ODC[s][i][a][g]*volume_commodity[g]<=sum(l in vehicles)number_vehicle_OPs_candidate_ODC[s][i][a][l]*volume_vehicle[l];


//13
forall(j in ODCs,r in DPs,s in scenarios)
  sum(g in oxygen)quantity_oxygen_ODCs_DPs[s][j][r][g]*weight_commodity[g]<=sum(l in vehicles)number_vehicle_ODCs_DPs[s][j][r][l]*weight_vehicle[l];


//14
forall(j in ODCs,r in DPs,s in scenarios)
  sum(g in oxygen)quantity_oxygen_ODCs_DPs[s][j][r][g]*volume_commodity[g]<=sum(l in vehicles)number_vehicle_ODCs_DPs[s][j][r][l]*volume_vehicle[l];


//15
forall(a in candidate_ODC,r in DPs,s in scenarios)
  sum(g in oxygen)quantity_oxygen_candidate_ODC_DPs[s][a][r][g]*weight_commodity[g]<=sum(l in vehicles)number_vehicle_candidate_ODC_DPs[s][a][r][l]*weight_vehicle[l];


//16
forall(a in candidate_ODC,r in DPs,s in scenarios)
  sum(g in oxygen)quantity_oxygen_candidate_ODC_DPs[s][a][r][g]*volume_commodity[g]<=sum(l in vehicles)number_vehicle_candidate_ODC_DPs[s][a][r][l]*volume_vehicle[l];


//17
forall(l in vehicles,s in scenarios)
  sum(i in OPs,j in ODCs) number_vehicle_OPs_ODCs[s][i][j][l]+
  sum(i in OPs,a in candidate_ODC)number_vehicle_OPs_candidate_ODC[s][i][a][l]+
  sum(j in ODCs,r in DPs)number_vehicle_ODCs_DPs[s][j][r][l]+
  sum(a in candidate_ODC,r in DPs)number_vehicle_candidate_ODC_DPs[s][a][r][l]<=
  total_number_vehicle[l];


//18
forall(s in scenarios)
sum(a in candidate_ODC)cost_establishing_candidate_ODC[a]*establishes_candidate_ODCs[a]+
sum(l in vehicles)per_unit_cost_vehicle[l]*(
sum(i in OPs,j in ODCs)distance_OPs_ODCs[i][j]*number_vehicle_OPs_ODCs[s][i][j][l]+
sum(i in OPs,a in candidate_ODC)distance_OPs_candidate_ODC[i][a]*number_vehicle_OPs_candidate_ODC[s][i][a][l]+
sum(j in ODCs,r in DPs)distance_ODCs_DPs[j][r]*number_vehicle_ODCs_DPs[s][j][r][l]+
sum(a in candidate_ODC,r in DPs)distance_candidate_ODC_DPs[a][r]*number_vehicle_candidate_ODC_DPs[s][a][r][l])<=
total_budget;


//19
forall(j in ODCs,r in DPs,g in oxygen,s in scenarios)quantity_oxygen_ODCs_DPs[s][j][r][g]>=0;
forall(a in candidate_ODC,r in DPs,g in oxygen,s in scenarios)quantity_oxygen_candidate_ODC_DPs[s][a][r][g]>=0;

//TIME
forall(i in OPs,j in ODCs,s in scenarios)
  (distance_OPs_ODCs[i][j]/Max_speed)*sum(l in vehicles)number_vehicle_OPs_ODCs[s][i][j][l]==time_OPs_ODCs[s][i][j];
  
//2
forall(i in OPs,a in candidate_ODC,s in scenarios)
  (distance_OPs_candidate_ODC[i][a]/Max_speed)*sum(l in vehicles)number_vehicle_OPs_candidate_ODC[s][i][a][l]==time_OPs_candidate_ODC[s][i][a];
  
//3
forall(j in ODCs,r in DPs,s in scenarios)
  (distance_ODCs_DPs[j][r]/Max_speed)*sum(l in vehicles)number_vehicle_ODCs_DPs[s][j][r][l]==time_ODCs_DPs[s][j][r];
  
//4
forall(a in candidate_ODC,r in DPs,s in scenarios)
  (distance_candidate_ODC_DPs[a][r]/Max_speed)*sum(l in vehicles)number_vehicle_candidate_ODC_DPs[s][a][r][l]==time_candidate_ODC_DPs[s][a][r];

w1+w2==1;

forall(s in scenarios)
  optimal_cost[s]==sum(s in scenarios)probablity_scen[s]*(sum(a in candidate_ODC)cost_establishing_candidate_ODC[a]*establishes_candidate_ODCs[a]+
sum(l in vehicles)per_unit_cost_vehicle[l]*(
sum(i in OPs,j in ODCs)distance_OPs_ODCs[i][j]*number_vehicle_OPs_ODCs[s][i][j][l]+
sum(i in OPs,a in candidate_ODC)distance_OPs_candidate_ODC[i][a]*number_vehicle_OPs_candidate_ODC[s][i][a][l]+
sum(j in ODCs,r in DPs)distance_ODCs_DPs[j][r]*number_vehicle_ODCs_DPs[s][j][r][l]+
sum(a in candidate_ODC,r in DPs)distance_candidate_ODC_DPs[a][r]*number_vehicle_candidate_ODC_DPs[s][a][r][l])+
sum(r in DPs,g in oxygen)shortage_cost_unsatisfied_demand_oxygen_DPs[g][r]*shortage_demand_oxygen_DPs[s][g][r]);
  

forall(s in scenarios)
  optimal_time[s]==sum(s in scenarios)probablity_scen[s]*(sum(i in OPs,j in ODCs)time_OPs_ODCs[s][i][j]+
sum(i in OPs,a in candidate_ODC)time_OPs_candidate_ODC[s][i][a]+
sum(j in ODCs,r in DPs)time_ODCs_DPs[s][j][r]+
sum(a in candidate_ODC,r in DPs)time_candidate_ODC_DPs[s][a][r]+
load_unload_time[s]*
(sum(i in OPs,j in ODCs,g in oxygen)quantity_oxygen_OPs_ODCs[s][i][j][g]+
sum(i in OPs,a in candidate_ODC,g in oxygen)quantity_oxygen_OPs_candidate_ODC[s][i][a][g]+
sum(j in ODCs,r in DPs,g in oxygen)quantity_oxygen_ODCs_DPs[s][j][r][g]+
sum(a in candidate_ODC,r in DPs,g in oxygen)quantity_oxygen_candidate_ODC_DPs[s][a][r][g]));


}