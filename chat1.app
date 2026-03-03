import os
import streamlit as st
import google.generativeai as genai

# --- Configure page ---
st.set_page_config(page_title="Gemini + Streamlit", page_icon="✨", layout="centered")

# --- API key handling ---
api_key = st.secrets.get("GEMINI_API_KEY") or os.getenv("GEMINI_API_KEY")
if not api_key:
    st.error("No API key found. Please set GEMINI_API_KEY in Streamlit secrets or environment.")
    st.stop()

genai.configure(api_key=api_key)

# --- Model selection ---
DEFAULT_MODEL = "gemini-1.5-flash"   # fast & cost-effective
ADVANCED_MODEL = "gemini-1.5-pro"    # more capable (slower/$$)

st.title("✨ Gemini + Streamlit (Text Generation)")

with st.sidebar:
    st.header("Settings")
    model_name = st.selectbox("Model", [DEFAULT_MODEL, ADVANCED_MODEL], index=0)
    temperature = st.slider("Creativity (temperature)", 0.0, 2.0, 0.9, 0.1)
    max_output_tokens = st.slider("Max output tokens", 64, 4096, 512, 64)
    top_p = st.slider("Top-p", 0.0, 1.0, 0.95, 0.05)
    top_k = st.slider("Top-k", 1, 64, 40, 1)

st.subheader("Prompt")
prompt = st.text_area("Enter your prompt:", height=150, placeholder="e.g., Write a 3-sentence summary about green hydrogen...")

col1, col2 = st.columns(2)
with col1:
    run_btn = st.button("Generate")
with col2:
    clear_btn = st.button("Clear")

if clear_btn:
    st.experimental_rerun()

if run_btn and prompt.strip():
    try:
        model = genai.GenerativeModel(model_name)
        with st.spinner("Thinking..."):
            response = model.generate_content(
                prompt,
                generation_config=genai.types.GenerationConfig(
                    temperature=temperature,
                    max_output_tokens=max_output_tokens,
                    top_p=top_p,
                    top_k=top_k,
                )
            )

        # Gemini responses may contain multiple parts; join text segments
        if hasattr(response, "text"):
            st.markdown("### Output")
            st.write(response.text)
        else:
            st.warning("No text returned. Try adjusting your prompt or model.")
    except Exception as e:
        st.error(f"Error: {e}")
