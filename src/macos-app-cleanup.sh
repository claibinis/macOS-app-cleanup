#!/bin/bash

# App Remnants Cleaner for macOS
# Finds leftover files from deleted applications
# Author: Christopher's cleanup script
# Date: January 2026

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   App Remnants Cleaner for macOS${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to check if directory exists and has files
check_location() {
    local location="$1"
    local app_name="$2"
    
    if [ -d "$location" ]; then
        local size=$(du -sh "$location" 2>/dev/null | cut -f1)
        echo -e "${YELLOW}Found:${NC} $app_name"
        echo -e "  Location: $location"
        echo -e "  Size: $size"
        return 0
    fi
    return 1
}

# Function to safely remove directory
remove_directory() {
    local dir="$1"
    if [ -d "$dir" ]; then
        echo -e "${GREEN}Removing:${NC} $dir"
        rm -rf "$dir"
        echo -e "${GREEN}✓ Removed${NC}"
    fi
}

# Array to store found remnants
declare -a REMNANTS_FOUND=()
declare -a REMNANTS_PATHS=()
declare -a REMNANTS_COMPANY=()
declare -a REMNANTS_APPNAME=()
declare -a REMNANTS_SIZE_KB=()  # Size in KB for sorting

# Comprehensive macOS system bundle identifiers to exclude
MACOS_SYSTEM_IDENTIFIERS=(
    "com.apple."
    "com.appleinternal."
    "com.macpaw."
    "system."
    "SystemConfiguration"
    "CoreSimulator"
    "CloudKit"
    "GameKit"
    "PassKit"
    "HealthKit"
    "HomeKit"
    "CarPlay"
    "WatchKit"
    "SiriKit"
    "WidgetKit"
    "AppKit"
    "Foundation"
    "CoreFoundation"
    "CoreData"
    "CoreGraphics"
    "CoreImage"
    "CoreVideo"
    "CoreAudio"
    "CoreMedia"
    "CoreText"
    "QuartzCore"
    "Metal"
    "MetalKit"
    "JavaScriptCore"
    "WebCore"
    "NetworkExtension"
)

echo -e "${BLUE}Scanning for application remnants...${NC}"
echo ""

# Common locations where app remnants hide
LOCATIONS=(
    "$HOME/Library/Application Support"
    "$HOME/Library/Caches"
    "$HOME/Library/Preferences"
    "$HOME/Library/Saved Application State"
    "$HOME/Library/Logs"
    "$HOME/Library/WebKit"
    "$HOME/Library/Cookies"
    "$HOME/Library/HTTPStorages"
    "$HOME/Library/Group Containers"
    "$HOME/Library/Containers"
)

# Get list of installed applications from multiple locations
echo -e "${BLUE}Building list of currently installed applications...${NC}"
INSTALLED_APPS=()
APP_SEARCH_PATHS=(
    "/Applications"
    "/Applications/Utilities"
    "/System/Applications"
    "/System/Applications/Utilities"
    "$HOME/Applications"
    "/System/Library/CoreServices/Applications"
)

for search_path in "${APP_SEARCH_PATHS[@]}"; do
    if [ -d "$search_path" ]; then
        while IFS= read -r app; do
            # Extract just the app name without .app extension
            app_name=$(basename "$app" .app)
            INSTALLED_APPS+=("$app_name")

            # Also add the bundle identifier if we can find it
            info_plist="$app/Contents/Info.plist"
            if [ -f "$info_plist" ]; then
                bundle_id=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$info_plist" 2>/dev/null || echo "")
                if [ -n "$bundle_id" ]; then
                    INSTALLED_APPS+=("$bundle_id")
                fi
            fi
        done < <(find "$search_path" -maxdepth 2 -name "*.app" -type d 2>/dev/null)
    fi
done

echo -e "${GREEN}Found ${#INSTALLED_APPS[@]} installed application references${NC}"
echo ""

# Create lookup string for faster searching (convert to lowercase and newline-separated)
INSTALLED_APPS_LOOKUP=""
for app in "${INSTALLED_APPS[@]}"; do
    INSTALLED_APPS_LOOKUP="${INSTALLED_APPS_LOOKUP}$(echo "$app" | tr '[:upper:]' '[:lower:]')
"
done

# Function to check if an app is installed (optimized with grep)
is_app_installed() {
    local check_name="$1"
    local check_name_lower=$(echo "$check_name" | tr '[:upper:]' '[:lower:]')
    # Use grep for much faster O(1) average lookup vs O(n) loop
    echo "$INSTALLED_APPS_LOOKUP" | grep -Fxq "$check_name_lower"
    return $?
}

# Function to check if item is a macOS system component
is_macos_system() {
    local item_name="$1"
    for identifier in "${MACOS_SYSTEM_IDENTIFIERS[@]}"; do
        if [[ "$item_name" == "$identifier"* ]]; then
            return 0
        fi
    done
    return 1
}

# Function to extract app metadata from bundle identifier or path
extract_app_metadata() {
    local item_path="$1"
    local item_name=$(basename "$item_path")
    local app_name=""
    local company_name=""

    # Try to read Info.plist if it exists (for Containers)
    local info_plist="$item_path/Info.plist"
    if [ -f "$info_plist" ]; then
        app_name=$(/usr/libexec/PlistBuddy -c "Print :CFBundleDisplayName" "$info_plist" 2>/dev/null || \
                   /usr/libexec/PlistBuddy -c "Print :CFBundleName" "$info_plist" 2>/dev/null || echo "")

        # Try to get company/vendor info
        company_name=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$info_plist" 2>/dev/null || echo "")
        if [ -n "$company_name" ]; then
            # Extract company from bundle ID (com.company.app -> company)
            if [[ "$company_name" =~ ^([a-z]+)\.([^.]+)\. ]]; then
                company_name="${BASH_REMATCH[2]}"
            fi
        fi
    fi

    # Parse bundle identifier patterns to extract app name and company
    if [ -z "$app_name" ]; then
        if [[ "$item_name" =~ ^com\.([^.]+)\.(.+)$ ]]; then
            company_name="${BASH_REMATCH[1]}"
            app_name="${BASH_REMATCH[2]}"
        elif [[ "$item_name" =~ ^org\.([^.]+)\.(.+)$ ]]; then
            company_name="${BASH_REMATCH[1]}"
            app_name="${BASH_REMATCH[2]}"
        elif [[ "$item_name" =~ ^io\.([^.]+)\.(.+)$ ]]; then
            company_name="${BASH_REMATCH[1]}"
            app_name="${BASH_REMATCH[2]}"
        elif [[ "$item_name" =~ ^net\.([^.]+)\.(.+)$ ]]; then
            company_name="${BASH_REMATCH[1]}"
            app_name="${BASH_REMATCH[2]}"
        elif [[ "$item_name" =~ ^dev\.([^.]+)\.(.+)$ ]]; then
            company_name="${BASH_REMATCH[1]}"
            app_name="${BASH_REMATCH[2]}"
        else
            app_name="$item_name"
            company_name="Unknown"
        fi
    fi

    # Clean up app name (remove common suffixes and capitalize)
    app_name=$(echo "$app_name" | sed 's/-/ /g' | sed 's/\./ /g')

    # Capitalize company name
    if [ -n "$company_name" ] && [ "$company_name" != "Unknown" ]; then
        company_name=$(echo "$company_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')
    fi

    # Return both values separated by |
    echo "${app_name}|${company_name}"
}

# Scan each location
TOTAL_FOUND=0
for location in "${LOCATIONS[@]}"; do
    if [ ! -d "$location" ]; then
        continue
    fi

    echo -e "${BLUE}Scanning:${NC} $location"

    # Find subdirectories (potential app remnants)
    while IFS= read -r item; do
        item_name=$(basename "$item")

        # Skip macOS system components
        if is_macos_system "$item_name"; then
            continue
        fi

        # Extract potential app name from bundle identifier or folder name
        # Common patterns: com.company.AppName, AppName, or org.company.AppName
        potential_app_name=""

        if [[ "$item_name" =~ ^com\.[^.]+\.(.+)$ ]]; then
            potential_app_name="${BASH_REMATCH[1]}"
        elif [[ "$item_name" =~ ^org\.[^.]+\.(.+)$ ]]; then
            potential_app_name="${BASH_REMATCH[1]}"
        elif [[ "$item_name" =~ ^io\.[^.]+\.(.+)$ ]]; then
            potential_app_name="${BASH_REMATCH[1]}"
        elif [[ "$item_name" =~ ^net\.[^.]+\.(.+)$ ]]; then
            potential_app_name="${BASH_REMATCH[1]}"
        elif [[ "$item_name" =~ ^dev\.[^.]+\.(.+)$ ]]; then
            potential_app_name="${BASH_REMATCH[1]}"
        else
            potential_app_name="$item_name"
        fi

        # Check if this app is NOT installed and NOT a bundle identifier match
        if ! is_app_installed "$potential_app_name" && ! is_app_installed "$item_name"; then
            # Found a potential remnant - calculate size ONCE and store in KB
            size_kb=$(du -sk "$item" 2>/dev/null | cut -f1 || echo "0")

            # Skip if size is 0 (empty or inaccessible)
            if [ "$size_kb" -eq 0 ]; then
                continue
            fi

            # Convert to human-readable
            if [ "$size_kb" -lt 1024 ]; then
                size_human="${size_kb}K"
            elif [ "$size_kb" -lt 1048576 ]; then
                size_mb=$((size_kb / 1024))
                size_human="${size_mb}M"
            else
                size_gb=$((size_kb / 1048576))
                size_human="${size_gb}G"
            fi

            # Extract metadata
            metadata=$(extract_app_metadata "$item")
            app_display_name=$(echo "$metadata" | cut -d'|' -f1)
            company_display_name=$(echo "$metadata" | cut -d'|' -f2)

            # Store metadata
            REMNANTS_FOUND+=("$item_name")
            REMNANTS_PATHS+=("$item")
            REMNANTS_APPNAME+=("$app_display_name")
            REMNANTS_COMPANY+=("$company_display_name")
            REMNANTS_SIZE_KB+=("$size_kb")
            TOTAL_FOUND=$((TOTAL_FOUND + 1))

            # Display with app name and company
            echo -e "  ${YELLOW}→${NC} ${GREEN}$app_display_name${NC} by ${BLUE}$company_display_name${NC} ${YELLOW}($size_human)${NC}"
        fi
    done < <(find "$location" -maxdepth 1 -mindepth 1 -type d 2>/dev/null)
done

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Scan Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ $TOTAL_FOUND -eq 0 ]; then
    echo -e "${GREEN}No application remnants found. Your Mac is clean!${NC}"
    exit 0
fi

echo -e "${YELLOW}Found $TOTAL_FOUND potential application remnants${NC}"
echo ""
echo -e "${RED}WARNING:${NC} This script found directories that may be from deleted apps."
echo -e "Review the list carefully before deleting."
echo ""

# Calculate total size from cached values (no du calls needed!)
TOTAL_SIZE=0
for size_kb in "${REMNANTS_SIZE_KB[@]}"; do
    TOTAL_SIZE=$((TOTAL_SIZE + size_kb))
done

TOTAL_SIZE_MB=$((TOTAL_SIZE / 1024))
if [ "$TOTAL_SIZE_MB" -gt 1024 ]; then
    TOTAL_SIZE_GB=$((TOTAL_SIZE_MB / 1024))
    echo -e "${BLUE}Estimated total size:${NC} ${TOTAL_SIZE_GB} GB"
else
    echo -e "${BLUE}Estimated total size:${NC} ${TOTAL_SIZE_MB} MB"
fi
echo ""

# Function to sort all arrays by size (largest first)
sort_by_size() {
    # Create index array
    indices=()
    for i in "${!REMNANTS_SIZE_KB[@]}"; do
        indices+=("$i")
    done

    # Bubble sort indices by size (descending)
    local n=${#indices[@]}
    for ((i = 0; i < n; i++)); do
        for ((j = 0; j < n - i - 1; j++)); do
            idx1=${indices[j]}
            idx2=${indices[j+1]}
            if [ "${REMNANTS_SIZE_KB[$idx1]}" -lt "${REMNANTS_SIZE_KB[$idx2]}" ]; then
                # Swap indices
                temp=${indices[j]}
                indices[j]=${indices[j+1]}
                indices[j+1]=$temp
            fi
        done
    done

    # Create new sorted arrays
    local sorted_found=()
    local sorted_paths=()
    local sorted_appname=()
    local sorted_company=()
    local sorted_size=()

    for idx in "${indices[@]}"; do
        sorted_found+=("${REMNANTS_FOUND[$idx]}")
        sorted_paths+=("${REMNANTS_PATHS[$idx]}")
        sorted_appname+=("${REMNANTS_APPNAME[$idx]}")
        sorted_company+=("${REMNANTS_COMPANY[$idx]}")
        sorted_size+=("${REMNANTS_SIZE_KB[$idx]}")
    done

    # Replace original arrays
    REMNANTS_FOUND=("${sorted_found[@]}")
    REMNANTS_PATHS=("${sorted_paths[@]}")
    REMNANTS_APPNAME=("${sorted_appname[@]}")
    REMNANTS_COMPANY=("${sorted_company[@]}")
    REMNANTS_SIZE_KB=("${sorted_size[@]}")
}

# Function to format size for display
format_size() {
    local size_kb=$1
    if [ "$size_kb" -lt 1024 ]; then
        echo "${size_kb}K"
    elif [ "$size_kb" -lt 1048576 ]; then
        size_mb=$((size_kb / 1024))
        echo "${size_mb}M"
    else
        size_gb=$((size_kb / 1048576))
        echo "${size_gb}G"
    fi
}

# Sort by size (largest first)
echo -e "${BLUE}Sorting by size...${NC}"
sort_by_size
echo ""

# Get unique companies for filtering
declare -a UNIQUE_COMPANIES=()
for company in "${REMNANTS_COMPANY[@]}"; do
    # Check if company already in list
    found=0
    for unique in "${UNIQUE_COMPANIES[@]}"; do
        if [ "$unique" = "$company" ]; then
            found=1
            break
        fi
    done
    if [ $found -eq 0 ]; then
        UNIQUE_COMPANIES+=("$company")
    fi
done

# Ask user what to do
echo -e "${YELLOW}What would you like to do?${NC}"
echo "1) Show top X largest items (quick cleanup)"
echo "2) Filter by company/author"
echo "3) Review all items sorted by size"
echo "4) Save list to file for manual review"
echo "5) Delete all found items (USE WITH CAUTION)"
echo "6) Exit without deleting anything"
echo ""
read -p "Enter choice (1-6): " choice

case $choice in
    1)
        # Show top X largest items
        echo ""
        read -p "How many largest items to show? (default: 10): " top_count
        top_count=${top_count:-10}

        if [ "$top_count" -gt "${#REMNANTS_FOUND[@]}" ]; then
            top_count=${#REMNANTS_FOUND[@]}
        fi

        echo ""
        echo -e "${BLUE}Top $top_count largest items:${NC}"
        echo ""

        for ((i=0; i<top_count; i++)); do
            size_human=$(format_size "${REMNANTS_SIZE_KB[$i]}")
            echo -e "${YELLOW}$((i+1)).${NC} ${GREEN}${REMNANTS_APPNAME[$i]}${NC} by ${BLUE}${REMNANTS_COMPANY[$i]}${NC} ${YELLOW}($size_human)${NC}"
            echo -e "   Path: ${REMNANTS_PATHS[$i]}"
        done

        echo ""
        read -p "Review and delete these items? (y/n): " review_choice

        if [[ "$review_choice" =~ ^[Yy]$ ]]; then
            echo ""
            for ((i=0; i<top_count; i++)); do
                size_human=$(format_size "${REMNANTS_SIZE_KB[$i]}")
                echo -e "${YELLOW}Item $((i+1)) of $top_count:${NC}"
                echo -e "  ${GREEN}App:${NC} ${REMNANTS_APPNAME[$i]}"
                echo -e "  ${BLUE}Company:${NC} ${REMNANTS_COMPANY[$i]}"
                echo -e "  ${YELLOW}Size:${NC} $size_human"
                echo -e "  Path: ${REMNANTS_PATHS[$i]}"
                read -p "Delete this item? (y/n/q to quit): " delete_choice

                case $delete_choice in
                    y|Y)
                        remove_directory "${REMNANTS_PATHS[$i]}"
                        ;;
                    q|Q)
                        echo -e "${BLUE}Exiting...${NC}"
                        break
                        ;;
                    *)
                        echo -e "${BLUE}Skipped${NC}"
                        ;;
                esac
                echo ""
            done
        fi
        ;;
    2)
        # Filter by company
        echo ""
        echo -e "${BLUE}Available companies:${NC}"
        for ((i=0; i<${#UNIQUE_COMPANIES[@]}; i++)); do
            # Count items for this company
            count=0
            total_size=0
            for j in "${!REMNANTS_COMPANY[@]}"; do
                if [ "${REMNANTS_COMPANY[$j]}" = "${UNIQUE_COMPANIES[$i]}" ]; then
                    count=$((count + 1))
                    total_size=$((total_size + REMNANTS_SIZE_KB[$j]))
                fi
            done
            size_human=$(format_size "$total_size")
            echo -e "${YELLOW}$((i+1)).${NC} ${UNIQUE_COMPANIES[$i]} ${BLUE}($count items, $size_human)${NC}"
        done

        echo ""
        read -p "Select company number (1-${#UNIQUE_COMPANIES[@]}): " company_num

        if [ "$company_num" -ge 1 ] && [ "$company_num" -le "${#UNIQUE_COMPANIES[@]}" ]; then
            selected_company="${UNIQUE_COMPANIES[$((company_num - 1))]}"
            echo ""
            echo -e "${BLUE}Items from: ${selected_company}${NC}"
            echo ""

            # Show filtered items
            filtered_indices=()
            for i in "${!REMNANTS_COMPANY[@]}"; do
                if [ "${REMNANTS_COMPANY[$i]}" = "$selected_company" ]; then
                    filtered_indices+=("$i")
                    size_human=$(format_size "${REMNANTS_SIZE_KB[$i]}")
                    echo -e "${YELLOW}${#filtered_indices[@]}.${NC} ${GREEN}${REMNANTS_APPNAME[$i]}${NC} ${YELLOW}($size_human)${NC}"
                    echo -e "   Path: ${REMNANTS_PATHS[$i]}"
                fi
            done

            echo ""
            read -p "Review and delete these items? (y/n): " review_choice

            if [[ "$review_choice" =~ ^[Yy]$ ]]; then
                echo ""
                for ((i=0; i<${#filtered_indices[@]}; i++)); do
                    idx=${filtered_indices[$i]}
                    size_human=$(format_size "${REMNANTS_SIZE_KB[$idx]}")
                    echo -e "${YELLOW}Item $((i+1)) of ${#filtered_indices[@]}:${NC}"
                    echo -e "  ${GREEN}App:${NC} ${REMNANTS_APPNAME[$idx]}"
                    echo -e "  ${BLUE}Company:${NC} ${REMNANTS_COMPANY[$idx]}"
                    echo -e "  ${YELLOW}Size:${NC} $size_human"
                    echo -e "  Path: ${REMNANTS_PATHS[$idx]}"
                    read -p "Delete this item? (y/n/q to quit): " delete_choice

                    case $delete_choice in
                        y|Y)
                            remove_directory "${REMNANTS_PATHS[$idx]}"
                            ;;
                        q|Q)
                            echo -e "${BLUE}Exiting...${NC}"
                            break
                            ;;
                        *)
                            echo -e "${BLUE}Skipped${NC}"
                            ;;
                    esac
                    echo ""
                done
            fi
        else
            echo -e "${RED}Invalid selection${NC}"
        fi
        ;;
    3)
        # Review all items sorted by size
        echo ""
        echo -e "${BLUE}Review Mode - All items sorted by size (largest first)${NC}"
        echo ""
        for i in "${!REMNANTS_FOUND[@]}"; do
            size_human=$(format_size "${REMNANTS_SIZE_KB[$i]}")
            echo -e "${YELLOW}Item $((i+1)) of ${#REMNANTS_FOUND[@]}:${NC}"
            echo -e "  ${GREEN}App:${NC} ${REMNANTS_APPNAME[$i]}"
            echo -e "  ${BLUE}Company:${NC} ${REMNANTS_COMPANY[$i]}"
            echo -e "  ${YELLOW}Size:${NC} $size_human"
            echo -e "  Path: ${REMNANTS_PATHS[$i]}"
            read -p "Delete this item? (y/n/q to quit): " delete_choice

            case $delete_choice in
                y|Y)
                    remove_directory "${REMNANTS_PATHS[$i]}"
                    ;;
                q|Q)
                    echo -e "${BLUE}Exiting...${NC}"
                    break
                    ;;
                *)
                    echo -e "${BLUE}Skipped${NC}"
                    ;;
            esac
            echo ""
        done
        ;;
    4)
        # Save to file
        output_file="$HOME/Desktop/app_remnants_$(date +%Y%m%d_%H%M%S).txt"
        echo "Application Remnants Found on $(date)" > "$output_file"
        echo "============================================" >> "$output_file"
        echo "" >> "$output_file"
        echo "Sorted by size (largest first)" >> "$output_file"
        echo "" >> "$output_file"
        for i in "${!REMNANTS_FOUND[@]}"; do
            size_human=$(format_size "${REMNANTS_SIZE_KB[$i]}")
            echo "App: ${REMNANTS_APPNAME[$i]}" >> "$output_file"
            echo "Company: ${REMNANTS_COMPANY[$i]}" >> "$output_file"
            echo "Size: $size_human" >> "$output_file"
            echo "Path: ${REMNANTS_PATHS[$i]}" >> "$output_file"
            echo "" >> "$output_file"
        done
        echo -e "${GREEN}List saved to:${NC} $output_file"
        ;;
    5)
        # Delete all
        echo ""
        echo -e "${RED}⚠️  WARNING: You are about to delete ALL found items!${NC}"
        read -p "Type 'DELETE ALL' to confirm: " confirm

        if [ "$confirm" = "DELETE ALL" ]; then
            echo ""
            for path in "${REMNANTS_PATHS[@]}"; do
                remove_directory "$path"
            done
            echo ""
            echo -e "${GREEN}✓ All remnants removed${NC}"
        else
            echo -e "${BLUE}Cancelled - nothing was deleted${NC}"
        fi
        ;;
    6)
        # Exit
        echo -e "${BLUE}Exiting without changes${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Done!${NC}"
echo ""
echo -e "${BLUE}Tip:${NC} You can also use AppCleaner (free) for automatic app removal"
echo -e "Download from: https://freemacsoft.net/appcleaner/"
