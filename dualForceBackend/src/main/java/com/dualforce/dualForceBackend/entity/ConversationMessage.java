package com.dualforce.dualForceBackend.entity;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

/**
 * Represents a message in a conversation history
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class ConversationMessage {
    private String content;
    private boolean user; // true for user messages, false for AI responses
}