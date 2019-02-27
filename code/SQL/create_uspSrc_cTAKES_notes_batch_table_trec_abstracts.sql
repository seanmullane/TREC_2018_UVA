USE TREC
GO

/****** Object:  StoredProcedure [Rptg].[uspSrc_cTAKES_notes_batch_table_trec_abstracts]    Script Date: 6/29/2018 1:33:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




--drop procedure [Rptg].[uspSrc_cTAKES_notes_batch_table_trec_abstracts] 

-- =====================================================================================
-- Create procedure [uspSrc_cTAKES_notes_batch_table_trec_abstracts]
-- =====================================================================================

CREATE PROCEDURE [Rptg].[uspSrc_cTAKES_notes_batch_table_trec_abstracts] (
	@beginDte DATE = NULL,
	@endDte DATE = NULL,
	@journal VARCHAR(255) = NULL,
	@textFilterLike VARCHAR(255) = NULL,
	@textFilterNotLike VARCHAR(255) = NULL,
	@analysisBatch VARCHAR(255),
	@quantity INT = '100000',
	@debug BIT = 0,
	@outStatus BIT OUTPUT
	)
--WITH EXECUTE AS OWNER
AS

SET NOCOUNT ON

/*******************************************************************************************
WHAT:	Rptg.[uspSrc_cTAKES_notes_batch_table_trec_abstracts_abstracts]

WHO :		Sean Mullane
WHEN:		11/29/2017
UPDATED:	07/02/2018
WHY :		Fetch ids of batch of publication abstracts to be processed by cTAKES. This is a modified version of [Rptg].[uspSrc_cTAKES_notes_batch_table_param_backanno]
--------------------------------------------------------------------------------------------
INFO:	
	INPUTS:
		  @beginDte DATE = NULL,
		  @endDte DATE = NULL,
		  @journal VARCHAR(255) = NULL,
	   	  @textFilterLike VARCHAR(255) = NULL,
	   	  @textFilterNotLike VARCHAR(255) = NULL,
		  @analysisBatch VARCHAR(255),
		  @quantity INT = 100000,
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
	@journalParam VARCHAR(255),
	@textFilterLikeParam VARCHAR(255),
	@textFilterNotLikeParam VARCHAR(255),
	@analysisBatchParam VARCHAR(255),
	@quantityParam INT
';



SELECT	@ParameterDefinitionCount = 
	@ParameterDefinition + ',@countOutputParam INT OUTPUT
';

-- Set barebones queries

SELECT	@SQL = N'
INSERT INTO Rptg.note_batch_ids
SELECT
    t2.pmid AS instance_id,
    ''pub_abstract'' AS doc_type
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

IF @journal IS NOT NULL
BEGIN
	SELECT @SQL = @SQL + N'
	AND txt.Note_Typ_IP_Nme = @journalParam ';
	SELECT @SQLCount = @SQLCount + N'
	AND txt.Note_Typ_IP_Nme = @journalParam ';
END

IF @textFilterLike IS NOT NULL
BEGIN
	SELECT @SQL = @SQL + N'
	AND SUBSTRING(doc_text, 1, 255) LIKE @textFilterLikeParam ';
	SELECT @SQLCount = @SQLCount + N'
	AND SUBSTRING(doc_text, 1, 255) LIKE @textFilterLikeParam ';
END 

IF @textFilterNotLike IS NOT NULL
BEGIN
	SELECT @SQL = @SQL + N'
	AND SUBSTRING(doc_text, 1, 255) NOT LIKE @textFilterNotLikeParam '; 
	SELECT @SQLCount = @SQLCount + N'
	AND SUBSTRING(doc_text, 1, 255) NOT LIKE @textFilterNotLikeParam '; 
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
	@journalParam = @journal,
	@textFilterLikeParam = @textFilterLike,
	@textFilterNotLikeParam = @textFilterNotLike,
	@analysisBatchParam = @analysisBatch,
	@quantityParam = @quantity,
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
		@journalParam = @journal,
		@textFilterLikeParam = @textFilterLike,
		@textFilterNotLikeParam = @textFilterNotLike,
		@analysisBatchParam = @analysisBatch,
		@quantityParam = @quantity;
	END
END

RETURN



GO


