USE TREC
GO

/****** Object:  StoredProcedure [Rptg].[uspSrc_cTAKES_single_note_trec_trial]    Script Date: 7/3/2018 12:20:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







--drop procedure [Rptg].[uspSrc_cTAKES_single_note_trec_trial] 

-- =====================================================================================
-- Create procedure [uspSrc_cTAKES_single_note_trec_trial]
-- =====================================================================================

CREATE PROCEDURE [Rptg].[uspSrc_cTAKES_single_note_trec_trial] (
	@nct_mod INT
	)
--WITH EXECUTE AS OWNER
AS

SET NOCOUNT ON

/*******************************************************************************************
WHAT:	Rptg.[uspSrc_cTAKES_single_note_trec_trial]

WHO :	Sean Mullane
WHEN:	11/29/2017
UPDATED: 07/03/2018
WHY :	Fetch clinical trial doc_text given an id, to be processed by cTAKES
--------------------------------------------------------------------------------------------
INFO:	
	INPUTS:
	      @nct_mod : an integer document ID
				
	OUTPUTS:
		  doc_text : varchar(max) representing the text of a full document
   
--------------------------------------------------------------------------------------------
MODS:
		

*******************************************************************************************/


select top 1 cc.doc_text
from TREC.txt.clinical_clean_combined cc
where cc.nct_mod = @nct_mod


GO


