#!/usr/bin/env python3
"""
Script to remove all ASCII characters (0-127) from a file.
This leaves only non-ASCII UTF-8 characters in the output.
"""

import argparse
import sys
import os


def remove_ascii_characters(input_file, output_file=None):
    """
    Remove all ASCII characters from input file and write to output file.

    Args:
        input_file (str): Path to input file
        output_file (str): Path to output file (defaults to input_file + '.no-ascii')
    """
    if output_file is None:
        output_file = input_file + ".no-ascii"

    try:
        # Read the input file as bytes to handle UTF-8 properly
        with open(input_file, "rb") as f:
            data = f.read()

        # Decode as UTF-8
        text = data.decode("utf-8", errors="replace")

        # Filter out ASCII characters (0-127)
        non_ascii_chars = [char for char in text if ord(char) > 127]
        filtered_text = "".join(non_ascii_chars)

        # Write the filtered text back as UTF-8
        with open(output_file, "w", encoding="utf-8") as f:
            f.write(filtered_text)

        # Print statistics
        original_chars = len(text)
        filtered_chars = len(filtered_text)
        removed_chars = original_chars - filtered_chars

        print(f"Processed: {input_file}")
        print(f"Output: {output_file}")
        print(f"Original characters: {original_chars}")
        print(f"Non-ASCII characters: {filtered_chars}")
        print(f"ASCII characters removed: {removed_chars}")
        print(f"Reduction: {removed_chars/original_chars*100:.1f}%")

    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found", file=sys.stderr)
        sys.exit(1)
    except UnicodeDecodeError as e:
        print(f"Error: Failed to decode '{input_file}' as UTF-8: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error processing file: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="Remove all ASCII characters (0-127) from a UTF-8 file",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s input.txt
  %(prog)s input.txt -o output.txt
  %(prog)s ../unicode_lipsum/wikipedia_mars/chinese.utf8.txt
        """,
    )

    parser.add_argument("input_file", help="Input UTF-8 file to process")
    parser.add_argument(
        "-o", "--output", help="Output file (defaults to input_file + .no-ascii)"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be removed without writing output",
    )

    args = parser.parse_args()

    if not os.path.exists(args.input_file):
        print(f"Error: Input file '{args.input_file}' does not exist", file=sys.stderr)
        sys.exit(1)

    if args.dry_run:
        # Just show statistics without writing output
        try:
            with open(args.input_file, "rb") as f:
                data = f.read()
            text = data.decode("utf-8", errors="replace")

            ascii_count = sum(1 for char in text if ord(char) <= 127)
            non_ascii_count = len(text) - ascii_count

            print(f"File: {args.input_file}")
            print(f"Total characters: {len(text)}")
            print(f"ASCII characters (would be removed): {ascii_count}")
            print(f"Non-ASCII characters (would be kept): {non_ascii_count}")
            print(f"Reduction would be: {ascii_count/len(text)*100:.1f}%")

        except Exception as e:
            print(f"Error analyzing file: {e}", file=sys.stderr)
            sys.exit(1)
    else:
        remove_ascii_characters(args.input_file, args.output)


if __name__ == "__main__":
    main()
