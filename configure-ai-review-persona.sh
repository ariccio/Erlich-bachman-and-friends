#!/bin/bash

# AI Code Review Persona Configuration Script
# Configures persona-specific settings for AI code review workflows
# Usage: ./configure-ai-review-persona.sh <persona_name>

set -euo pipefail

# Error tracking arrays
declare -a WARNINGS=()
declare -a ERRORS=()

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo "$1"  # No color to avoid diluting user attention
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
    WARNINGS+=("$1")
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    ERRORS+=("$1")
}

PERSONA="${1:-}"

if [[ -z "$PERSONA" ]]; then
    print_error "✗ Persona name required"
    print_info "Usage: $0 <persona_name>"
    print_info "Available personas: gilfoyle, monica, bachman"
    exit 1
fi

# Capture start time for duration tracking
START_TIME=$(date +%s)

print_info "Configuring AI review persona: $PERSONA"
print_info "Start time: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"

# Configure persona-specific settings
case "$PERSONA" in
    gilfoyle)
        INSTRUCTIONS_FILE=".github/copilot-instructions-Gilfoyle.md"
        PERSONA_NAME="Gilfoyle"
        BOT_ICON="●"
        MODEL="claude-sonnet-4-0"
        print_success "Configured Gilfoyle persona for technical superiority analysis"
        ;;
    monica)
        INSTRUCTIONS_FILE=".github/copilot-instructions-Monica.md"
        PERSONA_NAME="Monica Hall"
        BOT_ICON="◆"
        MODEL="claude-3-5-haiku-latest"
        print_success "Configured Monica persona for business analysis"
        ;;
    bachman)
        INSTRUCTIONS_FILE=".github/copilot-instructions-Bachman.md"
        PERSONA_NAME="Erlich Bachman"
        BOT_ICON="★"
        MODEL="claude-sonnet-4-0"
        print_success "Configured Bachman persona for ego-driven critiques"
        ;;
    *)
        print_error "✗ Unknown persona '$PERSONA'"
        print_info "Available personas: gilfoyle, monica, bachman"
        exit 1
        ;;
esac

# Export configuration for GitHub Actions
{
    echo "start_time=$START_TIME"
    echo "instructions_file=$INSTRUCTIONS_FILE"
    echo "persona_name=$PERSONA_NAME"
    echo "bot_icon=$BOT_ICON"
    echo "model=$MODEL"
} >> "$GITHUB_OUTPUT"

print_success "✓ Persona configuration completed"
print_info "Instructions file: $INSTRUCTIONS_FILE"
print_info "Persona name: $PERSONA_NAME"
print_info "Bot icon: $BOT_ICON"
print_info "Model: $MODEL"

# Display final summary
display_error_summary() {
    echo ""
    print_info "Operation Summary:"
    print_info "   • Total warnings: ${#WARNINGS[@]}"
    print_info "   • Total errors: ${#ERRORS[@]}"
    
    if [ ${#WARNINGS[@]} -gt 0 ]; then
        echo ""
        print_warning "Warnings encountered:"
        for warning in "${WARNINGS[@]}"; do
            echo "     • $warning"
        done
    fi
    
    if [ ${#ERRORS[@]} -gt 0 ]; then
        echo ""
        print_error "Errors encountered:"
        for error in "${ERRORS[@]}"; do
            echo "     • $error"
        done
    fi
    
    echo ""
    if [ ${#ERRORS[@]} -eq 0 ]; then
        print_success "All operations completed successfully!"
    else
        print_error "Some operations may not have completed due to errors above"
        return 1
    fi
}

display_error_summary