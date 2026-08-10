from __future__ import annotations

import json
import logging
from pathlib import Path
from typing import Any

import pandas as pd

PROJECT_ROOT=Path(__file__).resolve().parents[2]

RAW_DATA_DIRECTORY=PROJECT_ROOT / "data" / "raw" / "world_bank"
PROCESSED_DATA_DIRECTORY=PROJECT_ROOT / "data" / "processed" / "world_bank"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",

)

logger=logging.getLogger(__name__)


def load_raw_response(file_path:Path)->list[Any]:

    with file_path.open("r",encoding="utf-8") as input_file:
        payload=json.load(input_file)

    if not isinstance(payload,list) or len(payload)<2:
        raise ValueError(
             f"Unexpected World Bank response structure: {file_path.name}"
        )
    
    return payload


def transform_response(payload:list[Any])->pd.DataFrame:

    observations=payload[1]
    records=[]

    for observation in observations:
        records.append(
            {
                "country_code":observation.get("countryiso3code"),
                "country_name": observation.get("country", {}).get("value"),
                "indicator_code": observation.get("indicator", {}).get("id"),
                "indicator_name": observation.get("indicator", {}).get("value"),
                "year": observation.get("date"),
                "value": observation.get("value"),
            }
        )
    dataframe=pd.DataFrame(records)

    return dataframe


REQUIRED_COLUMNS = {
    "country_code",
    "country_name",
    "indicator_code",
    "indicator_name",
    "year",
    "value",
}


def validate_schema(dataframe:pd.DataFrame)->None:
    
    missing_columns=REQUIRED_COLUMNS-set(dataframe.columns)

    if missing_columns:
        raise ValueError(
            f"Missing required columns: {sorted(missing_columns)}"
        )
    

def clean_data_types(dataframe:pd.DataFrame)->pd.DataFrame:

    cleaned=dataframe.copy()

    cleaned["year"]=pd.to_numeric(
        cleaned["year"],
        errors="coerce",
    ).astype("Int64")

    cleaned["value"]=pd.to_numeric(
        cleaned["value"],
        errors="coerce"
    )

    return cleaned


def validate_required_values(dataframe: pd.DataFrame) -> None:

    required_fields = [
        "country_code",
        "indicator_code",
        "year",
    ]

    missing_counts = dataframe[required_fields].isna().sum()

    invalid_fields = missing_counts[missing_counts > 0]

    if not invalid_fields.empty:
        raise ValueError(
            "Missing mandatory values detected: "
            f"{invalid_fields.to_dict()}"
        )
    
def validate_duplicates(dataframe: pd.DataFrame) -> None:

    duplicate_mask = dataframe.duplicated(
        subset=[
            "country_code",
            "indicator_code",
            "year",
        ],
        keep=False,
    )

    duplicates = dataframe[duplicate_mask]

    if not duplicates.empty:
        raise ValueError(
            f"Duplicate observations detected: {len(duplicates)} rows"
        )
    

def validate_data(dataframe:pd.DataFrame)->None:

    validate_schema(dataframe)
    validate_required_values(dataframe)
    validate_duplicates(dataframe)

    logger.info(
        "Validation passed for %s rows.",
        len(dataframe),
    )

def save_processed_data(dataframe:pd.DataFrame,file_name:str,)->Path:

    PROCESSED_DATA_DIRECTORY.mkdir(
        parents=True,
        exist_ok=True,
    )

    output_path=PROCESSED_DATA_DIRECTORY / file_name

    dataframe.to_csv(
        output_path,
        index=False,
    )

    logger.info(
        "Saved processed dataset to %s.",
        output_path,
    )

    return output_path


def process_all_raw_files()->pd.DataFrame:

    raw_files=sorted(RAW_DATA_DIRECTORY.glob("*json"))

    if not raw_files:
        raise FileNotFoundError(
            f"No raw World Bank files found in {RAW_DATA_DIRECTORY}"
        )
    
    transformed_dataframes=[]

    logger.info(
        "Found %s raw World Bank files.",
        len(raw_files)
    )

    for file_path in raw_files:
        logger.info(
            "Transforming %s.",
            file_path.name,
        )

        payload = load_raw_response(file_path)
        dataframe = transform_response(payload)
        dataframe = clean_data_types(dataframe)
        validate_data(dataframe)
        transformed_dataframes.append(dataframe)
    
    combined_dataframe=pd.concat(
        transformed_dataframes,
        ignore_index=True,
    )

    validate_data(combined_dataframe)

    return combined_dataframe

def main()->None:

    try:
        dataframe = process_all_raw_files()

        output_path = save_processed_data(
            dataframe=dataframe,
            file_name="world_bank_indicators.csv",
        )

        logger.info(
            "Transformation complete. Rows: %s | Output: %s",
            len(dataframe),
            output_path,
        )

    except (
        FileNotFoundError,
        ValueError,
        json.JSONDecodeError,
    ) as error:
        logger.error(
            "Transformation failed: %s",
            error,
        )

        raise SystemExit(1) from error

if __name__ == "__main__":
    main()
    