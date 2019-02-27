
/*
Scratch and code to determine which relationship types can be easily paired with an inverse and then
mapped to that inverse. This mapping is used to turn the UMLS graph into an undirected graph
with high fidelity (if a relation has a proper inverse plus other non-proper-inverse paired
relationship types, those are pruned, along with relationships without proper inverses or only a very
small number).
*/

drop if exists table #temp_relationships

select 
m1.rela rela1, m2.rela rela2, count(*) cnt
into #temp_relationships
from umls.mrrel m1
inner join umls.mrrel m2 on m1.cui1 = m2.cui2
						and m1.cui2 = m2.cui1
						and m1.cui1 <> m1.cui2
where m1.rela is not null
and m1.sab in ('NCI', 'RXNORM', 'SNOMEDCT_US')
and m2.sab in ('NCI', 'RXNORM', 'SNOMEDCT_US')
group by m1.rela, m2.rela
order by 3 desc

drop if exists table #temp_relationships2

select 
m1.rela rela1, m2.rela rela2, count(*) cnt
into #temp_relationships2
from umls.mrrel m1
inner join umls.mrrel m2 on m1.cui1 = m2.cui2
						and m1.cui2 = m2.cui1
						and m1.cui1 <> m1.cui2
where m1.rela is not null
and m1.sab in ('NCI', 'RXNORM', 'SNOMEDCT_US')
and m2.sab in ('NCI', 'RXNORM', 'SNOMEDCT_US')
and m1.rela not in
('access_instrument_of'
,'access_of'
,'active_ingredient_of'
,'allele_has_abnormality'
,'allele_in_chromosomal_location'
,'alternative_of'
,'anatomic_structure_is_physical_part_of'
,'approach_of'
,'associated_etiologic_finding_of'
,'associated_finding_of'
,'associated_function_of'
,'associated_morphology_of'
,'associated_procedure_of'
,'associated_with_malfunction_of_gene_product'
,'biological_process_has_result_anatomy'
,'biological_process_involves_gene_product'
,'causative_agent_of'
,'chemical_or_drug_affects_cell_type_or_tissue'
,'chemical_or_drug_has_mechanism_of_action'
,'chemical_or_drug_has_physiologic_effect'
,'chemotherapy_regimen_has_component'
,'chromosome_mapped_to_disease'
,'clinical_course_of'
,'complex_has_physical_part'
,'component_of'
,'concept_in_subset'
,'conceptual_part_of'
,'consists_of'
,'contains'
,'course_of'
,'definitional_manifestation_of'
,'dependent_of'
,'direct_device_of'
,'direct_morphology_of'
,'direct_procedure_site_of'
,'direct_substance_of'
,'disease_excludes_abnormal_cell'
,'disease_excludes_cytogenetic_abnormality'
,'disease_excludes_finding'
,'disease_excludes_molecular_abnormality'
,'disease_excludes_normal_cell_origin'
,'disease_excludes_normal_tissue_origin'
,'disease_excludes_primary_anatomic_site'
,'disease_has_abnormal_cell'
,'disease_has_associated_gene'
,'disease_has_cytogenetic_abnormality'
,'disease_has_finding'
,'disease_has_metastatic_anatomic_site'
,'disease_has_molecular_abnormality'
,'disease_has_normal_cell_origin'
,'disease_has_normal_tissue_origin'
,'disease_has_primary_anatomic_site'
,'disease_is_grade'
,'disease_is_stage'
,'disease_mapped_to_gene'
,'disease_may_have_abnormal_cell'
,'disease_may_have_associated_disease'
,'disease_may_have_cytogenetic_abnormality'
,'disease_may_have_finding'
,'disease_may_have_molecular_abnormality'
,'dose_form_of'
,'doseformgroup_of'
,'due_to'
,'enzyme_metabolizes_chemical_or_drug'
,'eo_disease_has_associated_eo_anatomy'
,'eo_disease_has_property_or_attribute'
,'eo_disease_maps_to_human_disease'
,'episodicity_of'
,'excised_anatomy_has_procedure'
,'extent_of'
,'finding_context_of'
,'finding_informer_of'
,'finding_method_of'
,'finding_site_of'
,'focus_of'
,'form_of'
,'gene_encodes_gene_product'
,'gene_has_abnormality'
,'gene_has_physical_location'
,'gene_in_chromosomal_location'
,'gene_mutant_encodes_gene_product_sequence_variation'
,'gene_product_expressed_in_tissue'
,'gene_product_has_associated_anatomy'
,'gene_product_has_biochemical_function'
,'gene_product_has_chemical_classification'
,'gene_product_has_organism_source'
,'gene_product_has_structural_domain_or_motif'
,'gene_product_is_biomarker_type'
,'has_communication_with_wound'
,'has_gene_product_element'
,'has_salt_form'
,'includes'
,'indirect_device_of'
,'indirect_morphology_of'
,'indirect_procedure_site_of'
,'ingredient_of'
,'ingredients_of'
,'instrumentation_of'
,'intent_of'
,'interpretation_of'
,'interprets'
,'is_associated_anatomic_site_of'
,'is_associated_disease_of'
,'isa'
,'laterality_of'
,'measured_component_of'
,'measures'
,'method_of'
,'molecular_abnormality_involves_gene'
,'moved_to'
,'occurs_after'
,'occurs_in'
,'onset_of'
,'organism_has_gene'
,'parent_is_cdrh'
,'parent_is_nichd'
,'part_of'
,'partially_excised_anatomy_has_procedure'
,'pathogenesis_of_disease_involves_gene'
,'pathological_process_of'
,'pathway_has_gene_element'
,'precise_ingredient_of'
,'priority_of'
,'procedure_context_of'
,'procedure_device_of'
,'procedure_has_target_anatomy'
,'procedure_morphology_of'
,'procedure_site_of'
,'process_includes_biological_process'
,'process_initiates_biological_process'
,'process_involves_gene'
,'quantified_form_of'
,'refers_to'
,'reformulated_to'
,'regimen_has_accepted_use_for_disease'
,'replaces'
,'revision_status_of'
,'route_of_administration_of'
,'same_as'
,'severity_of'
,'specimen_of'
,'specimen_procedure_of'
,'specimen_source_identity_of'
,'specimen_source_morphology_of'
,'specimen_source_topography_of'
,'specimen_substance_of'
,'subject_relationship_context_of'
,'surgical_approach_of'
,'temporal_context_of'
,'temporally_follows'
,'tradename_of'
,'uses'
,'uses_access_device'
,'uses_device'
,'uses_energy'
,'uses_substance'
,'was_a'
,'has_method'
,'inverse_isa'
,'has_associated_morphology'
,'has_finding_site'
,'has_procedure_site'
,'has_direct_procedure_site'
,'has_ingredient'
,'has_causative_agent'
,'has_direct_morphology'
,'has_dose_form'
,'has_tradename'
,'constitutes'
,'is_interpreted_by'
,'subset_includes_concept'
,'has_direct_substance'
,'has_active_ingredient'
,'has_indirect_procedure_site'
,'has_pathological_process'
,'has_part'
,'has_occurrence'
,'has_access'
,'has_subject_relationship_context'
,'has_temporal_context'
,'has_direct_device'
,'has_finding_context'
,'has_interpretation'
,'has_doseformgroup'
,'is_abnormal_cell_of_disease'
,'has_intent'
,'gene_plays_role_in_process'
,'disease_has_associated_anatomic_site'
,'device_used_by'
,'has_associated_finding'
,'inverse_was_a'
,'has_component'
,'is_finding_of_disease'
,'moved_from'
,'has_access_instrument'
,'gene_product_plays_role_in_biological_process'
,'is_primary_anatomic_site_of_disease'
,'used_by'
,'gene_product_encoded_by_gene'
,'is_normal_tissue_origin_of_disease'
,'is_normal_cell_origin_of_disease'
,'may_be_finding_of_disease'
,'has_definitional_manifestation'
,'is_not_abnormal_cell_of_disease'
,'substance_used_by'
,'has_revision_status'
,'has_ingredients'
,'gene_product_is_element_in_pathway'
,'has_procedure_context'
,'gene_is_element_in_pathway'
,'is_component_of_chemotherapy_regimen'
,'has_associated_procedure'
,'has_precise_ingredient'
,'is_not_finding_of_disease'
,'has_finding_method'
,'has_physical_part_of_anatomic_structure'
,'may_be_cytogenetic_abnormality_of_disease'
,'has_course'
,'occurs_before'
,'access_device_used_by'
,'has_indirect_morphology'
,'has_approach'
,'has_measured_component'
,'has_focus'
,'may_be_molecular_abnormality_of_disease'
,'included_in'
,'cause_of'
,'temporally_followed_by'
,'is_biochemical_function_of_gene_product'
,'has_specimen_source_topography'
,'has_specimen'
,'has_nichd_parent'
,'has_quantified_form'
,'has_clinical_course'
,'is_not_normal_cell_origin_of_disease'
,'has_laterality'
,'possibly_equivalent_to'
,'gene_mapped_to_disease'
,'has_conceptual_part'
,'is_chromosomal_location_of_gene'
,'is_associated_anatomy_of_gene_product'
,'has_surgical_approach'
,'gene_found_in_organism'
,'has_finding_informer'
,'has_specimen_procedure'
,'has_specimen_substance'
,'eo_anatomy_is_associated_with_eo_disease'
,'is_not_primary_anatomic_site_of_disease'
,'replaced_by'
,'has_form'
,'is_structural_domain_or_motif_of_gene_product'
,'is_stage_of_disease'
,'gene_associated_with_disease'
,'has_priority'
,'contained_in'
,'has_cdrh_parent'
,'has_procedure_morphology'
,'wound_has_communication_with'
,'human_disease_maps_to_eo_disease'
,'has_free_acid_or_base_form'
,'has_procedure_device'
,'is_physiologic_effect_of_chemical_or_drug'
,'may_be_associated_disease_of_disease'
,'has_extent'
,'is_chemical_classification_of_gene_product'
,'has_onset'
,'tissue_is_expression_site_of_gene_product'
,'is_mechanism_of_action_of_chemical_or_drug'
,'is_organism_source_of_gene_product'
,'is_molecular_abnormality_of_disease'
,'may_be_abnormal_cell_of_disease'
,'energy_used_by'
,'is_physical_location_of_gene'
,'is_grade_of_disease'
,'disease_has_associated_disease'
,'has_associated_etiologic_finding'
,'gene_involved_in_pathogenesis_of_disease'
,'is_not_normal_tissue_origin_of_disease'
,'target_anatomy_has_procedure'
,'gene_involved_in_molecular_abnormality'
,'chemical_or_drug_is_metabolized_by_enzyme'
,'referred_to_by'
,'has_severity'
,'has_route_of_administration'
,'gene_product_malfunction_associated_with_disease'
,'biological_process_is_part_of_process'
,'has_specimen_source_identity'
,'procedure_has_excised_anatomy'
,'has_instrumentation'
,'gene_product_is_physical_part_of'
,'is_not_cytogenetic_abnormality_of_disease'
,'gene_product_sequence_variation_encoded_by_gene_mutant'
,'is_not_molecular_abnormality_of_disease'
,'has_specimen_source_morphology'
,'cell_type_or_tissue_affected_by_chemical_or_drug'
,'has_indirect_device'
,'has_dependent'
,'biomarker_type_includes_gene_product'
,'disease_has_accepted_treatment_with_regimen'
,'is_property_or_attribute_of_eo_disease'
,'is_cytogenetic_abnormality_of_disease'
,'is_abnormality_of_gene'
,'has_episodicity'
,'disease_mapped_to_chromosome'
,'procedure_has_partially_excised_anatomy'
,'abnormality_associated_with_allele'
,'has_alternative'
,'is_metastatic_anatomic_site_of_disease'
,'biological_process_has_initiator_process'
,'chromosomal_location_of_allele'
,'reformulation_of'
,'measured_by'
,'anatomy_originated_from_biological_process'
,'has_associated_function')
group by m1.rela, m2.rela
order by 3 desc


-- create ref table of relations with their inverses
create table UMLS.TREC_rela_inv_map (
rela1 varchar(60),
rela2 varchar(60)
)

insert into UMLS.TREC_rela_inv_map values ('access_instrument_of','has_access_instrument')
insert into UMLS.TREC_rela_inv_map values ('access_of','has_access')
insert into UMLS.TREC_rela_inv_map values ('active_ingredient_of','has_active_ingredient')
insert into UMLS.TREC_rela_inv_map values ('allele_has_abnormality','abnormality_associated_with_allele')
insert into UMLS.TREC_rela_inv_map values ('allele_in_chromosomal_location','chromosomal_location_of_allele')
insert into UMLS.TREC_rela_inv_map values ('allele_plays_altered_role_in_process','process_altered_by_allele')
insert into UMLS.TREC_rela_inv_map values ('alternative_of','has_alternative')
insert into UMLS.TREC_rela_inv_map values ('anatomic_structure_is_physical_part_of','has_physical_part_of_anatomic_structure')
insert into UMLS.TREC_rela_inv_map values ('approach_of','has_approach')
insert into UMLS.TREC_rela_inv_map values ('associated_etiologic_finding_of','has_associated_etiologic_finding')
insert into UMLS.TREC_rela_inv_map values ('associated_finding_of','has_associated_finding')
insert into UMLS.TREC_rela_inv_map values ('associated_function_of','has_associated_function')
insert into UMLS.TREC_rela_inv_map values ('associated_morphology_of','has_associated_morphology')
insert into UMLS.TREC_rela_inv_map values ('associated_procedure_of','has_associated_procedure')
insert into UMLS.TREC_rela_inv_map values ('associated_with_malfunction_of_gene_product','gene_product_malfunction_associated_with_disease')
insert into UMLS.TREC_rela_inv_map values ('biological_process_has_associated_location','is_location_of_biological_process')
insert into UMLS.TREC_rela_inv_map values ('biological_process_has_result_anatomy','anatomy_originated_from_biological_process')
insert into UMLS.TREC_rela_inv_map values ('biological_process_involves_gene_product','gene_product_plays_role_in_biological_process')
insert into UMLS.TREC_rela_inv_map values ('causative_agent_of','has_causative_agent')
insert into UMLS.TREC_rela_inv_map values ('chemical_or_drug_affects_cell_type_or_tissue','cell_type_or_tissue_affected_by_chemical_or_drug')
insert into UMLS.TREC_rela_inv_map values ('chemical_or_drug_affects_gene_product','gene_product_affected_by_chemical_or_drug')
insert into UMLS.TREC_rela_inv_map values ('chemical_or_drug_has_mechanism_of_action','is_mechanism_of_action_of_chemical_or_drug')
insert into UMLS.TREC_rela_inv_map values ('chemical_or_drug_has_physiologic_effect','is_physiologic_effect_of_chemical_or_drug')
insert into UMLS.TREC_rela_inv_map values ('chemotherapy_regimen_has_component','is_component_of_chemotherapy_regimen')
insert into UMLS.TREC_rela_inv_map values ('chromosome_involved_in_cytogenetic_abnormality','cytogenetic_abnormality_involves_chromosome')
insert into UMLS.TREC_rela_inv_map values ('chromosome_mapped_to_disease','disease_mapped_to_chromosome')
insert into UMLS.TREC_rela_inv_map values ('clinical_course_of','has_clinical_course')
insert into UMLS.TREC_rela_inv_map values ('complex_has_physical_part','gene_product_is_physical_part_of')
insert into UMLS.TREC_rela_inv_map values ('component_of','has_component')
insert into UMLS.TREC_rela_inv_map values ('concept_in_subset','subset_includes_concept')
insert into UMLS.TREC_rela_inv_map values ('conceptual_part_of','has_conceptual_part')
insert into UMLS.TREC_rela_inv_map values ('consists_of','constitutes')
insert into UMLS.TREC_rela_inv_map values ('contains','contained_in')
insert into UMLS.TREC_rela_inv_map values ('course_of','has_course')
insert into UMLS.TREC_rela_inv_map values ('definitional_manifestation_of','has_definitional_manifestation')
insert into UMLS.TREC_rela_inv_map values ('dependent_of','has_dependent')
insert into UMLS.TREC_rela_inv_map values ('direct_device_of','has_direct_device')
insert into UMLS.TREC_rela_inv_map values ('direct_morphology_of','has_direct_morphology')
insert into UMLS.TREC_rela_inv_map values ('direct_procedure_site_of','has_direct_procedure_site')
insert into UMLS.TREC_rela_inv_map values ('direct_substance_of','has_direct_substance')
insert into UMLS.TREC_rela_inv_map values ('disease_excludes_abnormal_cell','is_not_abnormal_cell_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_excludes_cytogenetic_abnormality','is_not_cytogenetic_abnormality_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_excludes_finding','is_not_finding_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_excludes_molecular_abnormality','is_not_molecular_abnormality_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_excludes_normal_cell_origin','is_not_normal_cell_origin_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_excludes_normal_tissue_origin','is_not_normal_tissue_origin_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_excludes_primary_anatomic_site','is_not_primary_anatomic_site_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_has_abnormal_cell','is_abnormal_cell_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_has_associated_gene','gene_associated_with_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_has_cytogenetic_abnormality','is_cytogenetic_abnormality_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_has_finding','is_finding_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_has_metastatic_anatomic_site','is_metastatic_anatomic_site_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_has_molecular_abnormality','is_molecular_abnormality_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_has_normal_cell_origin','is_normal_cell_origin_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_has_normal_tissue_origin','is_normal_tissue_origin_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_has_primary_anatomic_site','is_primary_anatomic_site_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_is_grade','is_grade_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_is_stage','is_stage_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_mapped_to_gene','gene_mapped_to_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_may_have_abnormal_cell','may_be_abnormal_cell_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_may_have_associated_disease','may_be_associated_disease_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_may_have_cytogenetic_abnormality','may_be_cytogenetic_abnormality_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_may_have_finding','may_be_finding_of_disease')
insert into UMLS.TREC_rela_inv_map values ('disease_may_have_molecular_abnormality','may_be_molecular_abnormality_of_disease')
insert into UMLS.TREC_rela_inv_map values ('dose_form_of','has_dose_form')
insert into UMLS.TREC_rela_inv_map values ('doseformgroup_of','has_doseformgroup')
insert into UMLS.TREC_rela_inv_map values ('due_to','cause_of')
insert into UMLS.TREC_rela_inv_map values ('enzyme_metabolizes_chemical_or_drug','chemical_or_drug_is_metabolized_by_enzyme')
insert into UMLS.TREC_rela_inv_map values ('eo_disease_has_associated_eo_anatomy','eo_anatomy_is_associated_with_eo_disease')
insert into UMLS.TREC_rela_inv_map values ('eo_disease_has_property_or_attribute','is_property_or_attribute_of_eo_disease')
insert into UMLS.TREC_rela_inv_map values ('eo_disease_maps_to_human_disease','human_disease_maps_to_eo_disease')
insert into UMLS.TREC_rela_inv_map values ('episodicity_of','has_episodicity')
insert into UMLS.TREC_rela_inv_map values ('excised_anatomy_has_procedure','procedure_has_excised_anatomy')
insert into UMLS.TREC_rela_inv_map values ('extent_of','has_extent')
insert into UMLS.TREC_rela_inv_map values ('finding_context_of','has_finding_context')
insert into UMLS.TREC_rela_inv_map values ('finding_informer_of','has_finding_informer')
insert into UMLS.TREC_rela_inv_map values ('finding_method_of','has_finding_method')
insert into UMLS.TREC_rela_inv_map values ('finding_site_of','has_finding_site')
insert into UMLS.TREC_rela_inv_map values ('focus_of','has_focus')
insert into UMLS.TREC_rela_inv_map values ('form_of','has_form')
insert into UMLS.TREC_rela_inv_map values ('gene_encodes_gene_product','gene_product_encoded_by_gene')
insert into UMLS.TREC_rela_inv_map values ('gene_has_abnormality','is_abnormality_of_gene')
insert into UMLS.TREC_rela_inv_map values ('gene_has_physical_location','is_physical_location_of_gene')
insert into UMLS.TREC_rela_inv_map values ('gene_in_chromosomal_location','is_chromosomal_location_of_gene')
insert into UMLS.TREC_rela_inv_map values ('gene_mutant_encodes_gene_product_sequence_variation','gene_product_sequence_variation_encoded_by_gene_mutant')
insert into UMLS.TREC_rela_inv_map values ('gene_product_expressed_in_tissue','tissue_is_expression_site_of_gene_product')
insert into UMLS.TREC_rela_inv_map values ('gene_product_has_associated_anatomy','is_associated_anatomy_of_gene_product')
insert into UMLS.TREC_rela_inv_map values ('gene_product_has_biochemical_function','is_biochemical_function_of_gene_product')
insert into UMLS.TREC_rela_inv_map values ('gene_product_has_chemical_classification','is_chemical_classification_of_gene_product')
insert into UMLS.TREC_rela_inv_map values ('gene_product_has_organism_source','is_organism_source_of_gene_product')
insert into UMLS.TREC_rela_inv_map values ('gene_product_has_structural_domain_or_motif','is_structural_domain_or_motif_of_gene_product')
insert into UMLS.TREC_rela_inv_map values ('gene_product_is_biomarker_type','biomarker_type_includes_gene_product')
insert into UMLS.TREC_rela_inv_map values ('has_communication_with_wound','wound_has_communication_with')
insert into UMLS.TREC_rela_inv_map values ('has_gene_product_element','gene_product_is_element_in_pathway')
insert into UMLS.TREC_rela_inv_map values ('has_salt_form','has_free_acid_or_base_form')
insert into UMLS.TREC_rela_inv_map values ('has_target','is_target')
insert into UMLS.TREC_rela_inv_map values ('includes','included_in')
insert into UMLS.TREC_rela_inv_map values ('indirect_device_of','has_indirect_device')
insert into UMLS.TREC_rela_inv_map values ('indirect_morphology_of','has_indirect_morphology')
insert into UMLS.TREC_rela_inv_map values ('indirect_procedure_site_of','has_indirect_procedure_site')
insert into UMLS.TREC_rela_inv_map values ('ingredient_of','has_ingredient')
insert into UMLS.TREC_rela_inv_map values ('ingredients_of','has_ingredients')
insert into UMLS.TREC_rela_inv_map values ('instrumentation_of','has_instrumentation')
insert into UMLS.TREC_rela_inv_map values ('intent_of','has_intent')
insert into UMLS.TREC_rela_inv_map values ('interpretation_of','has_interpretation')
insert into UMLS.TREC_rela_inv_map values ('interprets','is_interpreted_by')
insert into UMLS.TREC_rela_inv_map values ('is_associated_anatomic_site_of','disease_has_associated_anatomic_site')
insert into UMLS.TREC_rela_inv_map values ('is_associated_disease_of','disease_has_associated_disease')
insert into UMLS.TREC_rela_inv_map values ('isa','inverse_isa')
insert into UMLS.TREC_rela_inv_map values ('laterality_of','has_laterality')
insert into UMLS.TREC_rela_inv_map values ('measured_component_of','has_measured_component')
insert into UMLS.TREC_rela_inv_map values ('measures','measured_by')
insert into UMLS.TREC_rela_inv_map values ('method_of','has_method')
insert into UMLS.TREC_rela_inv_map values ('molecular_abnormality_involves_gene','gene_involved_in_molecular_abnormality')
insert into UMLS.TREC_rela_inv_map values ('moved_to','moved_from')
insert into UMLS.TREC_rela_inv_map values ('occurs_after','occurs_before')
insert into UMLS.TREC_rela_inv_map values ('occurs_in','has_occurrence')
insert into UMLS.TREC_rela_inv_map values ('onset_of','has_onset')
insert into UMLS.TREC_rela_inv_map values ('organism_has_gene','gene_found_in_organism')
insert into UMLS.TREC_rela_inv_map values ('parent_is_cdrh','has_cdrh_parent')
insert into UMLS.TREC_rela_inv_map values ('parent_is_nichd','has_nichd_parent')
insert into UMLS.TREC_rela_inv_map values ('part_of','has_part')
insert into UMLS.TREC_rela_inv_map values ('partially_excised_anatomy_has_procedure','procedure_has_partially_excised_anatomy')
insert into UMLS.TREC_rela_inv_map values ('pathogenesis_of_disease_involves_gene','gene_involved_in_pathogenesis_of_disease')
insert into UMLS.TREC_rela_inv_map values ('pathological_process_of','has_pathological_process')
insert into UMLS.TREC_rela_inv_map values ('pathway_has_gene_element','gene_is_element_in_pathway')
insert into UMLS.TREC_rela_inv_map values ('precise_ingredient_of','has_precise_ingredient')
insert into UMLS.TREC_rela_inv_map values ('priority_of','has_priority')
insert into UMLS.TREC_rela_inv_map values ('procedure_context_of','has_procedure_context')
insert into UMLS.TREC_rela_inv_map values ('procedure_device_of','has_procedure_device')
insert into UMLS.TREC_rela_inv_map values ('procedure_has_target_anatomy','target_anatomy_has_procedure')
insert into UMLS.TREC_rela_inv_map values ('procedure_morphology_of','has_procedure_morphology')
insert into UMLS.TREC_rela_inv_map values ('procedure_site_of','has_procedure_site')
insert into UMLS.TREC_rela_inv_map values ('process_includes_biological_process','biological_process_is_part_of_process')
insert into UMLS.TREC_rela_inv_map values ('process_initiates_biological_process','biological_process_has_initiator_process')
insert into UMLS.TREC_rela_inv_map values ('process_involves_gene','gene_plays_role_in_process')
insert into UMLS.TREC_rela_inv_map values ('quantified_form_of','has_quantified_form')
insert into UMLS.TREC_rela_inv_map values ('refers_to','referred_to_by')
insert into UMLS.TREC_rela_inv_map values ('reformulated_to','reformulation_of')
insert into UMLS.TREC_rela_inv_map values ('regimen_has_accepted_use_for_disease','disease_has_accepted_treatment_with_regimen')
insert into UMLS.TREC_rela_inv_map values ('replaces','replaced_by')
insert into UMLS.TREC_rela_inv_map values ('revision_status_of','has_revision_status')
insert into UMLS.TREC_rela_inv_map values ('route_of_administration_of','has_route_of_administration')
insert into UMLS.TREC_rela_inv_map values ('same_as','possibly_equivalent_to')
insert into UMLS.TREC_rela_inv_map values ('severity_of','has_severity')
insert into UMLS.TREC_rela_inv_map values ('specimen_of','has_specimen')
insert into UMLS.TREC_rela_inv_map values ('specimen_procedure_of','has_specimen_procedure')
insert into UMLS.TREC_rela_inv_map values ('specimen_source_identity_of','has_specimen_source_identity')
insert into UMLS.TREC_rela_inv_map values ('specimen_source_morphology_of','has_specimen_source_morphology')
insert into UMLS.TREC_rela_inv_map values ('specimen_source_topography_of','has_specimen_source_topography')
insert into UMLS.TREC_rela_inv_map values ('specimen_substance_of','has_specimen_substance')
insert into UMLS.TREC_rela_inv_map values ('subject_relationship_context_of','has_subject_relationship_context')
insert into UMLS.TREC_rela_inv_map values ('surgical_approach_of','has_surgical_approach')
insert into UMLS.TREC_rela_inv_map values ('temporal_context_of','has_temporal_context')
insert into UMLS.TREC_rela_inv_map values ('temporally_follows','temporally_followed_by')
insert into UMLS.TREC_rela_inv_map values ('tradename_of','has_tradename')
insert into UMLS.TREC_rela_inv_map values ('uses','used_by')
insert into UMLS.TREC_rela_inv_map values ('uses_access_device','access_device_used_by')
insert into UMLS.TREC_rela_inv_map values ('uses_device','device_used_by')
insert into UMLS.TREC_rela_inv_map values ('uses_energy','energy_used_by')
insert into UMLS.TREC_rela_inv_map values ('uses_substance','substance_used_by')
insert into UMLS.TREC_rela_inv_map values ('was_a','inverse_was_a')
	


/*
Now calculate exclusivity of relationships
*/

-- map all relationship pairs to single relationship
-- rela1 has full set, rela2 has half set
-- materialize into temp table

drop if exists table #temp_rel_map

select rela1, rela2
into #temp_rel_map
from
(
	select rela1 rela1, rela1 rela2
	from trec.TREC_rela_inv_map
	union
	select rela2 rela1, rela1 rela2
	from trec.TREC_rela_inv_map
) t
create clustered index IX_rela1 on #temp_rel_map(rela1, rela2)


drop if exists table #tau_x_table

-- calculate tau value for each cui1 cui2 pair (this is symmetric using the relationship pair mappings, so don't need to do reverse)
select m1.cui1, map.rela2, count(distinct cui2) tau_x
into #tau_x_table
from trec.mrrel m1
inner join #temp_rel_map map on m1.rela = map.rela1
where m1.rela is not null
and m1.sab in ('NCI', 'RXNORM', 'SNOMEDCT_US')
group by m1.cui1, map.rela2
;
create clustered index IX_tau on #tau_x_table(cui1, rela2)


-- create a reduced-scope table to define possible relationships between cuis using symmetric mappings

drop if exists table #mrrel_subset

select distinct m1.CUI1, map.rela2, m1.CUI2
into #mrrel_subset
from trec.mrrel m1
inner join #temp_rel_map map on m1.RELA = map.rela1
where m1.rela is not null
and m1.sab in ('NCI', 'RXNORM', 'SNOMEDCT_US')
and m1.CUI1 <> m1.CUI2
order by m1.cui1;
create clustered index IX_cui1 on #mrrel_subset(cui1)
create nonclustered index IX_rela on #mrrel_subset(rela2)
create nonclustered index IX_cui2 on #mrrel_subset(cui2)


-- get the necessary rows set up to calculate exclusivity
-- Need one row for every combination of CUI1, rela, CUI2. Each row needs count of edges of type "rela" from CUI1 and count of edges of type "rela" from CUI2
-- can calculate exclusivity by using the formula 1/(tau_x + tau_y - 1) across the row for each (CUI1, CUI2, rela) triple

drop if exists table #temp_exclusivity

select m1.cui1, m1.rela2 AS rela, t1.tau_x, m1.cui2, t2.tau_x AS tau_y
into #temp_exclusivity
from #mrrel_subset m1
inner join #tau_x_table t1			on m1.cui1 = t1.cui1
									and m1.rela2 = t1.rela2
inner join #tau_x_table t2			on m1.cui2 = t2.cui1
									and m1.rela2 = t2.rela2

-- return table of edges with exclusivity for python to ingest (save results as csv) (should be around 3.6M rows)

select cui1, cui2, rela, 1/(CONVERT(FLOAT, tau_x) + CONVERT(FLOAT, tau_y) - 1) as exclusivity
INTO trec.exclusivity
from #temp_exclusivity te
inner join trec.TREC_rela_inv_map map on te.RELA = map.rela1
order by te.cui1


