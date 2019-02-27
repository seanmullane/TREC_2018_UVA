USE TREC
GO

/****** Object:  StoredProcedure [Rptg].[uspSrc_cTAKES_notes_batch_table_trec]    Script Date: 6/29/2018 1:33:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




--drop procedure [Rptg].[uspSrc_cTAKES_notes_batch_table_trec] 

-- =====================================================================================
-- Create procedure [uspSrc_cTAKES_notes_batch_table_trec]
-- =====================================================================================

CREATE PROCEDURE [Rptg].[uspSrc_cTAKES_notes_batch_table_trec] (
	@beginDte DATE = NULL,
	@endDte DATE = NULL,
	@analysisBatch VARCHAR(255),
	@quantity INT = '100000',
	@docType VARCHAR(50) = 'pub_abstract', -- other option is 'clinical_trial'
	@debug BIT = 0,
	@outStatus BIT OUTPUT
	)
--WITH EXECUTE AS OWNER
AS

SET NOCOUNT ON

/*******************************************************************************************
WHAT:	Rptg.[uspSrc_cTAKES_notes_batch_table_trec_abstracts]

WHO :		Sean Mullane
WHEN:		11/29/2017
UPDATED:	07/02/2018
WHY :		Fetch ids of batch of publication abstracts to be processed by cTAKES. This is a modified version of [Rptg].[uspSrc_cTAKES_notes_batch_table_param_backanno]
--------------------------------------------------------------------------------------------
INFO:	
	INPUTS:
		  @beginDte DATE = NULL,
		  @endDte DATE = NULL,
		  @analysisBatch VARCHAR(255),
		  @quantity INT = 100000,
		  @docType VARCHAR(50) = 'pub_abstract',
	   	  @debug BIT = 0
				
	OUTPUTS:
		  @outStatus = 0

	SIDE EFFECTS:
		Modifies following tables:
			Rptg.note_batch_ids

   
--------------------------------------------------------------------------------------------
MODS:
		

*******************************************************************************************/

DECLARE @noteCount INT

SET @outStatus = 0

-- Declare variables

DECLARE @SQL NVARCHAR(4000);
DECLARE @SQLCount NVARCHAR(4000);
DECLARE @ParameterDefinition NVARCHAR(2000);
DECLARE @ParameterDefinitionCount NVARCHAR(2000);

-- Set definitions

SELECT	@ParameterDefinition = '
	@beginDteParam DATE,
	@endDteParam DATE,
	@analysisBatchParam VARCHAR(255),
	@quantityParam INT,
	@docTypeParam VARCHAR(50)
';



SELECT	@ParameterDefinitionCount = 
	@ParameterDefinition + ',@countOutputParam INT OUTPUT
';

-- Set barebones queries

IF @docType = 'pub_abstract'
BEGIN

	SELECT	@SQL = N'
	INSERT INTO Rptg.note_batch_ids
	SELECT
		t2.pmid AS instance_id,
		@docTypeParam AS doc_type
	FROM (
	  SELECT TOP(@quantityParam)
		pmid
	  FROM [txt].[abstracts_clean] txt
	  WHERE 1 = 1
	';

	SELECT	@SQLCount = N'
	SELECT @countOutputParam = count(pmid)
	FROM (
	  SELECT TOP(@quantityParam)
		pmid
	  FROM [txt].[abstracts_clean] txt
	  WHERE 1 = 1
	';

	-- Add relevant parameters

	IF @beginDte IS NOT NULL
	BEGIN
		SELECT @SQL = @SQL + N'
		AND convert(date, pub_year) >= @beginDteParam ';
		SELECT @SQLCount = @SQLCount + N'
		AND convert(date, pub_year) >= @beginDteParam ';
	END

	IF @endDte IS NOT NULL
	BEGIN
		SELECT @SQL = @SQL + N'
		AND convert(date, pub_year) < @endDteParam ';
		SELECT @SQLCount = @SQLCount + N'
		AND convert(date, pub_year) < @endDteParam ';
	END

	-- Put it all together

	SELECT @SQL = @SQL + N'
		AND pmid NOT IN (
			SELECT instance_id
			FROM dbo.document doc
			WHERE doc.analysis_batch = @analysisBatchParam
		)
	) t2
	';

	SELECT @SQLCount = @SQLCount + N'
		AND pmid NOT IN (
			SELECT instance_id
			FROM dbo.document doc
			WHERE doc.analysis_batch = @analysisBatchParam
			UNION
			SELECT instance_id
			FROM Rptg.note_batch_ids
		)
	) t2;
	RETURN
	';

END
ELSE IF @docType = 'clinical_trial'
BEGIN

	SELECT	@SQL = N'
	INSERT INTO Rptg.note_batch_ids
	SELECT
		t2.nct_mod AS instance_id,
		@docTypeParam AS doc_type
	FROM (
	  SELECT TOP(@quantityParam)
		nct_mod
	  FROM [txt].[clinical_clean_combined] txt
	  WHERE 1 = 1
	';

	SELECT	@SQLCount = N'
	SELECT @countOutputParam = count(nct_mod)
	FROM (
	  SELECT TOP(@quantityParam)
		nct_mod
	  FROM [txt].[clinical_clean_combined] txt
	  WHERE 1 = 1
	';

		-- Put it all together

	SELECT @SQL = @SQL + N'
		AND nct_mod NOT IN (
			SELECT instance_id
			FROM dbo.document doc
			WHERE doc.analysis_batch = @analysisBatchParam
		)
	) t2
	';

	SELECT @SQLCount = @SQLCount + N'
		AND nct_mod NOT IN (
			SELECT instance_id
			FROM dbo.document doc
			WHERE doc.analysis_batch = @analysisBatchParam
			UNION
			SELECT instance_id
			FROM Rptg.note_batch_ids
		)
	) t2;
	RETURN
	';

END
ELSE 
BEGIN
	RETURN 1
END



-- part before UNION is documents that have already been annotated
-- part after UNION is documents that are already in the Rptg.note_batch_ids (i.e. the queue)


IF @debug = 1
BEGIN
	PRINT @SQL
	PRINT @SQLCount
	PRINT @ParameterDefinitionCount
END

-- Execute

BEGIN
	
	EXEC sp_executeSQL 
	@SQLCount,
	@ParameterDefinitionCount,
	@beginDteParam = @beginDte,
	@endDteParam = @endDte,
	@analysisBatchParam = @analysisBatch,
	@quantityParam = @quantity,
	@docTypeParam = @docType,
	@countOutputParam = @noteCount OUTPUT;
		
	SELECT @noteCount;

	IF @debug = 0
	BEGIN
		TRUNCATE TABLE Rptg.note_batch_ids;

		EXEC sp_executeSQL 
		@SQL,
		@ParameterDefinition,
		@beginDteParam = @beginDte,
		@endDteParam = @endDte,
		@analysisBatchParam = @analysisBatch,
		@quantityParam = @quantity,
		@docTypeParam = @docType;
	END
END

RETURN



GO


