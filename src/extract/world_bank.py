from __future__ import annotations
from src.config import COUNTRIES,END_YEAR,START_YEAR,INDICATORS
import json
import logging
from datetime import UTC, datetime
from pathlib import Path
from typing import Any
import requests


BASE_URL="https://api.worldbank.org/v2"
DEFAULT_TIMEOUT_SECONDS=30

PROJECT_ROOT=Path(__file__).resolve().parents[2]
RAW_DATA_DIRECTORY=PROJECT_ROOT / "data" / "raw" / "world_bank"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
)

logger=logging.getLogger(__name__)

def fetch_indicator_data(
        country_code:str,
        indicator_code:str,
        start_year:int,
        end_year:int,
)->list[Any]:
     """Retrieve indicator observations from the World Bank API.

    Args:
        country_code: ISO three-letter country code, for example ``ZAF``.
        indicator_code: World Bank indicator code.
        start_year: First year to retrieve.
        end_year: Final year to retrieve.

    Returns:
        The complete JSON response returned by the API.

    Raises:
        ValueError: If the supplied years are invalid.
        requests.RequestException: If the API request fails.
        RuntimeError: If the API response does not contain observation data.
    """
     if start_year>end_year:
          raise ValueError("start_year cannot be greater than endd_year")
     
     url=(f"{BASE_URL}/country/{country_code}/indicator/{indicator_code}")

     params={
          "format":"json",
          "per_page":100,
     }

     logger.info(
          "Requesting indicator %s for %s from %s to %s.",
          indicator_code,
          country_code,
          start_year,
          end_year,
     )

     response=requests.get(
          url,
          params=params,
          timeout=DEFAULT_TIMEOUT_SECONDS,
     )

     response.raise_for_status()

     payload=response.json()
     

     if not isinstance(payload,list) or len(payload)<2:
          raise RuntimeError(
               "The World Bank API returned an unexpected response structure"
          )
     observations = payload[1]
     filtered_observations = [
        observation
        for observation in observations
        if start_year <= int(observation["date"]) <= end_year
     ]
     if not filtered_observations:
        raise RuntimeError(
            "The World Bank API returned no observations for the requested period."
        )
     payload[1] = filtered_observations

     logger.info(
        "Retrieved %s observations between %s and %s.",
        len(filtered_observations),
        start_year,
        end_year,
    )

     return payload


def save_raw_response(
    payload: list[Any],
    country_code: str,
    indicator_code: str,
) -> Path:
    """Save an unmodified API response as a timestamped JSON file."""
    RAW_DATA_DIRECTORY.mkdir(parents=True, exist_ok=True)

    extraction_timestamp = datetime.now(UTC).strftime("%Y%m%dT%H%M%SZ")
    safe_indicator_code = indicator_code.replace(".", "_")

    output_path = RAW_DATA_DIRECTORY / (
        f"{country_code.lower()}_"
        f"{safe_indicator_code.lower()}_"
        f"{extraction_timestamp}.json"
    )

    with output_path.open("w", encoding="utf-8") as output_file:
        json.dump(payload, output_file, indent=2, ensure_ascii=False)

    logger.info("Saved raw response to %s.", output_path)

    return output_path

def main() -> None:

    successfull_extractions=0
    failed_extractions=0

    for country_code,country_name in COUNTRIES.items():
        for indicator_code,indicator_name in INDICATORS.items():

            logger.info(
                "Starting extraction: %s | %s",
                country_name,
                indicator_name,
            )

            try:
                payload = fetch_indicator_data(
                    country_code=country_code,
                    indicator_code=indicator_code,
                    start_year=START_YEAR,
                    end_year=END_YEAR,
                )

                output_path = save_raw_response(
                    payload=payload,
                    country_code=country_code,
                    indicator_code=indicator_code,
                )

                logger.info(
                    "Extraction completed successfully: %s",output_path
                )

                successfull_extractions+=1

            except (ValueError, RuntimeError, requests.RequestException) as error:
                
                failed_extractions+=1
                logger.error(
                    "Extraction failed for %s | %s: %s",
                      country_name,
                      indicator_name,
                      error,
                      )
    logger.info(
        "Extraction run complete. Successful: %s | Failed: %s",
        successfull_extractions,
        failed_extractions,
    )

if __name__ == "__main__":
    main()

