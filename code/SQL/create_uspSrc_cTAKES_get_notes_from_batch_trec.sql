USE TREC
GO

/****** Object:  StoredProcedure [Rptg].[uspSrc_cTAKES_get_notes_from_batch_trec]    Script Date: 7/3/2018 12:13:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




--drop procedure [Rptg].[uspSrc_cTAKES_get_notes_from_batch_trec] 

-- =====================================================================================
-- Create procedure [uspSrc_cTAKES_get_notes_from_batch_trec]
-- =====================================================================================

CREATE PROCEDURE [Rptg].[uspSrc_cTAKES_get_notes_from_batch_trec] (
	@pipelineCount INT, 
	@pipelineNumber INT
	)
--WITH EXECUTE AS OWNER
AS

SET NOCOUNT ON

/*******************************************************************************************
WHAT:	Rptg.[uspSrc_cTAKES_get_notes_from_batch_trec]

WHO :		Sean Mullane
WHEN:		12/04/2017
UPDATED:	
WHY :		Fetch ids of batch of notes to be processed by cTAKES from batch staging table for back-annotation
--------------------------------------------------------------------------------------------
INFO:	
	INPUTS:
		  @pipelineCount INT, 
		  @pipelineNumber INT
				
	OUTPUTS:
		  instance_id,
		  doc_type

	SIDE EFFECTS:
		

   
--------------------------------------------------------------------------------------------
MODS:
		

*******************************************************************************************/

--Return an equal part of the note IDs from the note batch staging table

SELECT 
	instance_id,
	doc_type
FROM [Rptg].[note_batch_ids]
WHERE instance_id % @pipelineCount = @pipelineNumber


GO


